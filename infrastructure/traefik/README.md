# Traefik Local Reverse Proxy Recommendation

This directory captures the recommended ingress-layer design for the current VirtualBox homelab. The goal is a local-network reverse proxy that is easy to expand, follows Kubernetes and homelab best practices, and stays within the resource limits of the VM nodes.

## Why this option is the best fit

For the current cluster state, Traefik is the best balance of:

- low operational complexity
- easy service onboarding
- good local-network host routing
- strong Kubernetes integration
- low memory and CPU overhead compared with API-gateway-heavy alternatives
- compatibility with Kubernetes-native service discovery

This is a better fit than Gloo Gateway for a private homelab playground running on 8 GB RAM / 4 vCPU nodes, especially with Longhorn, Headlamp, Keycloak, and Grafana/Prometheus already present.

## Decision summary

### Gloo vs Traefik

| Topic | Gloo Gateway | Traefik |
|---|---|---|
| Primary role | API gateway with policy and routing features | Kubernetes ingress controller with simple, flexible routing |
| Resource usage | Higher | Lower |
| Operational complexity | Higher | Lower |
| Ease of adding services | Good, but more platform-style config | Very good |
| Best for | API-centric environments and policy-heavy gateway layers | Private homelabs, local ingress, service aggregation |
| Risk on current hardware | Moderate to high | Low |
| Best recommendation for this lab | Secondary / niche | Primary recommendation |

### Recommendation for this project

Use Traefik as the main local reverse proxy and keep cluster services behind hostname-based routing, such as:

- grafana.vbox.local
- keycloak.vbox.local
- headlamp.vbox.local
- longhorn.vbox.local
- prometheus.vbox.local
- future apps using their own hostnames

This creates a clean local ingress layer without requiring each service to be exposed directly via individual LoadBalancer IPs.

## Functionality comparison: Gloo vs Traefik

| Functionality area | Gloo Gateway | Traefik |
|---|---|---|
| HTTP routing | Very strong | Very strong |
| TLS termination | Strong | Strong |
| AuthN/AuthZ integration | Strong, more platform-like | Good, especially with forward auth and middleware |
| API gateway semantics | Excellent | Good, but not the primary focus |
| Local homelab usability | Good | Excellent |
| Service onboarding speed | Moderate | Fast |
| Learning curve | Medium-high | Low-medium |
| Operational maintenance | Higher | Lower |

## Resource usage and hardware impact

| Category | Gloo Gateway | Traefik |
|---|---|---|
| Typical memory footprint | Higher | Lower |
| Typical CPU overhead | Higher | Lower |
| Impact with existing cluster workloads | More noticeable | Less noticeable |
| Good fit for 8 GB / 4 vCPU VMs | Borderline | Good |
| Long-term scaling cost | Higher | Lower |

Given the current service load, Traefik is more likely to remain stable and easier to maintain without crowding the nodes.

## Pros and cons

### Traefik pros

- Lightweight and easy to operate
- Clear Kubernetes ingress model
- Good for local LAN hostnames and internal routing
- Easy to expand as new services are added
- Strong ecosystem and documentation
- Official OCI Helm chart and official image are available

### Traefik cons

- Not as “gateway-heavy” as API gateway products
- Some advanced policy patterns require more custom config
- If you later want a very rich API-gateway platform, it may feel limiting

### Gloo pros

- Strong API-centric policy model
- Excellent if your future focus is gateway and policy logic
- Good for managed route/auth patterns at scale

### Gloo cons

- More resource overhead
- More architectural complexity
- Higher operational burden in a small homelab environment
- Not the best fit for a limited-memory VM cluster

## Recommendations on when to use what

| Scenario | Best choice | Why |
|---|---|---|
| Home lab with 2-10 internal services | Traefik | Simpler, lighter, faster to adopt |
| Need a standard ingress layer for apps and dashboards | Traefik | Lowest maintenance and easiest route-to-service mapping |
| Need an API gateway with advanced policy enforcement | Gloo | Better long-term if gateway semantics matter more than simplicity |
| Existing cluster already loaded with storage and monitoring | Traefik | Less resource pressure |
| You want to learn production-style platform patterns | Gloo or Traefik depending on focus | Gloo is more gateway-heavy; Traefik is more practical |

## Integration and conflict considerations with common homelab stacks

### 1) Existing services in this cluster

Current services to consider:

- Cilium: networking layer; should remain the data-plane and service routing baseline
- Longhorn: storage; not directly in the ingress path
- Headlamp: cluster dashboard; can be routed behind a host like headlamp.vbox.local
- Keycloak: identity provider; can be exposed to the ingress but should not be fronted by a conflicting route strategy
- Grafana/Prometheus: observability stack; can be fronted by ingress using host-based routing

Conflict risk: none major, as long as hostnames are unique and the ingress rules map to the right services.

### 2) Top 5 common private homelab stacks

| Stack | Typical purpose | Traefik integration | Gloo integration | Notes |
|---|---|---|---|---|
| Home Assistant | Smart-home hub | Excellent | Good, but unnecessary | Best behind a dedicated hostname |
| Jellyfin / Plex / Emby | Media server | Excellent | Good but overkill | Simple host routing works best |
| Nextcloud / Immich | File sync / photos | Excellent | Good but heavier | Ingress route per app is straightforward |
| AdGuard Home / Pi-hole | DNS filtering | Good | Good | Better placed behind a dedicated hostname and local-only policy |
| Portainer / Uptime Kuma / monitoring | Admin and monitoring | Excellent | Fine | Great fit for ingress-host separation |

### Key integration note

These services usually work best when routed by hostname and namespace, not by broad wildcard patterns. This preserves clarity and reduces accidental misrouting.

## Best-practice design for this homelab

### Recommended ingress architecture

- One Traefik installation in a dedicated namespace such as ingress
- One internal LoadBalancer or NodePort service for local access
- Host-based routing for each exposed service
- Keep all apps behind unique hostnames on the LAN
- Keep local DNS entries simple, such as:
  - grafana.vbox.local
  - keycloak.vbox.local
  - headlamp.vbox.local
  - longhorn.vbox.local
- Keep Cilium as the separate networking substrate, not as the primary app gateway layer unless you intentionally want an all-in-one platform setup

### Security practices

- Use TLS for local hostnames whenever practical
- Prefer local CA or internal cert automation over plain HTTP in long-lived setups
- Keep ingress rules explicit and deny broad wildcard catches unless necessary
- Avoid exposing everything publicly; keep this local-network-only by default
- Use least-privilege service access between ingress and backends

## Resource recommendation

For this exact environment, the recommended deployment is:

- Traefik with official OCI Helm chart and official Traefik image
- One dedicated ingress namespace
- One LoadBalancer service for the LAN
- Host-based routing for the installed apps
- No Gloo unless you decide to turn this into a more API-platform-like lab later

This matches your requirements:

- local-network only reverse proxy
- easy to scale by adding services and hostnames
- safe and trusted software
- low resource burden
- clear Kubernetes-native integration

## Final recommendation

Choose Traefik as the default ingress layer for the current lab.

Use Gloo only if you intentionally want to move toward an advanced API gateway layer and can accept more complexity and resource overhead.

For a homelab playground, Traefik is the better architected and less risky choice.
