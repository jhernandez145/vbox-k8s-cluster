# Traefik Local Reverse Proxy Setup

This document provides a step-by-step implementation path for a local-network Traefik ingress layer that fits the current VirtualBox homelab and keeps the existing services intact.

## Goals

- Keep the cluster local-network only.
- Use one ingress layer for multiple services.
- Preserve the existing Cilium networking layer.
- Avoid exposing app services directly to the LAN without a clear ingress policy.
- Keep resource usage modest for 8 GB / 4 vCPU VM nodes.
- Use safe, official, and industry-standard tooling where possible.

## Current service baseline

The existing cluster already contains:

- Longhorn for storage
- Headlamp for cluster management
- Keycloak for identity
- Grafana and Prometheus for observability
- Cilium as the networking layer

This setup should be treated as the application baseline. Traefik will sit in front of these services as a clean ingress layer.

## By-the-numbers implementation plan

### 1) Confirm the current baseline before changing anything

Run the following from the master node:

```bash
kubectl get svc -A
kubectl get pods -A
kubectl get ns
```

Purpose:
- Confirm that the active services are healthy.
- Identify existing LoadBalancer IPs and avoid collisions.
- Prevent an ingress IP conflict with already assigned addresses.

### 2) Reserve a dedicated ingress IP in the LAN pool

Choose a free IP in the same 192.168.102.x network, such as `192.168.102.205`.

Example validation:

```bash
kubectl get svc -A | grep -E '192\.168\.102\.'
```

Purpose:
- Make sure the chosen IP is not already assigned.
- Keep the ingress entrypoint stable and consistent.

### 3) Create the ingress namespace

```bash
kubectl create namespace ingress
```

Purpose:
- Keep ingress resources isolated from application namespaces.
- Simplify routing and maintenance.

### 4) Prepare a values file for Traefik

Create a file such as `infrastructure/traefik/traefik-values.yaml`.

Example structure:

```yaml
# Traefik values for a private homelab.
# This file configures a single ingress entrypoint for local services.

providers:
  kubernetesIngress:
    enabled: true
    publishedService:
      enabled: true

service:
  type: LoadBalancer
  annotations:
    # Keep this private and local-network only.
    # This is intentionally not public-facing.
    io.cilium/lb-ipam-ips: "192.168.102.205"

ports:
  web:
    port: 80
    targetPort: web
    protocol: TCP
  websecure:
    port: 443
    targetPort: websecure
    protocol: TCP

logs:
  general:
    level: INFO

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

securityContext:
  runAsNonRoot: true
  runAsUser: 65532

ingressClass:
  enabled: true
  isDefaultClass: true
```

Purpose:
- Keep Traefik lightweight enough for the VM profile.
- Use one LoadBalancer IP for the ingress entrypoint.
- Keep the config minimal and explicit.

### 5) Install Traefik with the official OCI chart

Run the following:

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update
helm upgrade --install traefik oci://ghcr.io/traefik/helm/traefik \
  --namespace ingress \
  --create-namespace \
  --values infrastructure/traefik/traefik-values.yaml
```

Purpose:
- Use the official Traefik chart and image.
- Keep the install aligned with the official project ecosystem.
- Ensure the ingress layer is installed before routing apps.

### 6) Validate the Traefik install

```bash
kubectl get pods -n ingress
kubectl get svc -n ingress
kubectl get ingressclass
```

Expected result:
- Traefik pods should be running.
- The service should show a stable external IP such as `192.168.102.205`.
- The ingress class should be present and default.

### 7) Configure local DNS or host entries

On any machine that needs access, add entries like:

```text
192.168.102.205  grafana.vbox.local
192.168.102.205  headlamp.vbox.local
192.168.102.205  keycloak.vbox.local
192.168.102.205  longhorn.vbox.local
192.168.102.205  prometheus.vbox.local
```

Purpose:
- Avoid hardcoding private IPs directly in the browser.
- Use consistent local hostnames for all services.
- Keeps the lab portable within the local LAN.

### 8) Add host-based ingress routes for the existing services

Create a file such as `infrastructure/traefik/ingress-routes.yaml`.

Example:

```yaml
# Example ingress routes.
# Each host maps to a specific service so routing stays explicit and easy to audit.

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
spec:
  ingressClassName: traefik
  rules:
    - host: grafana.vbox.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: monitoring-grafana
                port:
                  number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: headlamp-ingress
  namespace: headlamp
spec:
  ingressClassName: traefik
  rules:
    - host: headlamp.vbox.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: headlamp
                port:
                  number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: keycloak-ingress
  namespace: identity
spec:
  ingressClassName: traefik
  rules:
    - host: keycloak.vbox.local
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: keycloak-keycloak-chart-http
                port:
                  number: 80
```

Apply it:

```bash
kubectl apply -f infrastructure/traefik/ingress-routes.yaml
```

Purpose:
- Route by hostname instead of ad hoc IP access.
- Keep routing explicit and easier to audit.
- Reduce accidental route conflicts.

### 9) Add TLS for local hostnames

For a homelab, use either:

- a private CA with cert-manager
- or a self-signed local certificate with a trusted internal root

Short example using a self-signed local cert is not ideal for production, but acceptable for a private LAN lab when you trust the local CA.

Recommended best practice:
- Use a private CA if you want stable TLS trust.
- Use cert-manager with a local ClusterIssuer if you want a cleaner long-term setup.

Example validation:

```bash
kubectl get certificates -A
kubectl get secrets -A | grep -E 'tls|cert'
```

Purpose:
- Keep local web traffic encrypted.
- Avoid exposing plain HTTP for admin interfaces.

### 10) Protect admin endpoints and identity flows

For the exposed admin services:

- Headlamp: prefer a token-based login flow and keep the service behind the ingress.
- Keycloak: keep it behind the ingress and use a clearly defined hostname.
- Grafana: prefer OIDC or a local trusted auth flow behind the ingress.

Recommended safety measure:
- Keep ingress and identity flows separate from public internet exposure.
- Never expose the service directly without a hostname or reverse-proxy policy.

### 11) Validate route health and service connectivity

Run:

```bash
kubectl get ingress -A
kubectl describe ingress -n monitoring
kubectl describe ingress -n headlamp
kubectl describe ingress -n identity
```

Then test from a LAN machine:

```bash
curl -I https://grafana.vbox.local
curl -I https://headlamp.vbox.local
curl -I https://keycloak.vbox.local
```

If you use self-signed certificates, add `-k` for validation in testing:

```bash
curl -k -I https://grafana.vbox.local
```

Purpose:
- Confirm each route resolves to the correct backend service.
- Confirm TLS is working.
- Confirm no ingress misroutes or broken backend references exist.

### 12) Monitor and keep it stable

Run:

```bash
kubectl get pods -n ingress
kubectl logs -n ingress deploy/traefik --tail=100
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -50
```

Purpose:
- Detect route issues early.
- Verify Traefik is healthy after each config change.
- Use logs and events for debugging.

### 13) Keep it maintainable

- Pin chart and image versions.
- Keep all values files commented.
- Add new hostnames as new services are introduced.
- Keep one ingress entrypoint instead of exposing each service with ad hoc rules.
- Revalidate all hostname routes after any ingress change.

## Security best-practice checklist

- Local network only
- No public IP exposure
- Unique hostnames per app
- TLS on all routes
- No direct API exposure without ingress rules
- Internal CA or local certs used for trusted local HTTPS
- Explicit least-privilege service access
- No broad wildcard route patterns
- Minimal resource requests/limits in the ingress deployment

## Recommended final topology

- Cilium remains the cluster networking substrate.
- Traefik becomes the local ingress entrypoint.
- Existing services stay in their namespaces.
- One ingress IP serves all local hostnames.
- Access stays on the LAN with local hostnames and internal certificates.

## Practical final recommendation

This is the best implementation path for your current cluster and constraints:

- use Traefik
- use one ingress service on a dedicated private IP
- use local hostnames on the LAN
- keep certificate trust internal
- keep all routes explicit and documented
- avoid public exposure entirely

This gives you a scalable, cleaner ingress architecture while respecting your current hardware, homelab learning goals, and safe operational practices.
