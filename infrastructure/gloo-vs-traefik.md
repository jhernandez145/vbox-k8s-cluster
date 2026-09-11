# Gloo Gateway vs Traefik for a Private Homelab

This file is a comparison reference for ingress and gateway choices in a private homelab. It is intended to support decision-making before implementation, not to replace the operational documentation for the chosen solution.

## Comparison table: infrastructure interaction and usage

| Category | Gloo Gateway | Traefik |
|---|---|---|
| Role | API gateway and policy-aware ingress layer | Ingress controller and reverse proxy |
| Primary operational model | Gateway-oriented, often API first | Service-oriented, app first |
| Typical service discovery | Kubernetes services, gateway route config, policy layer | Kubernetes ingress + service discovery |
| Local homelab fit | Good, but heavier | Excellent |
| Ease of adding services | Good, but more config discipline needed | Very good |
| Routing model | Gateway + virtual host + policy | Ingress + host/path routing |
| Rate limiting and policies | Strong | Good, but more middleware-style |
| TLS termination | Strong | Strong |
| Observability integration | Strong, often enterprise-oriented | Very good, simple to integrate |
| Resource usage | Higher | Lower |
| Operational burden | Higher | Lower |
| Best for | API-first systems and gateway-heavy setups | Home lab apps, dashboards, internal services |

## Functionality comparison

| Functionality | Gloo Gateway | Traefik |
|---|---|---|
| HTTP routing | Excellent | Excellent |
| Host-based routing | Excellent | Excellent |
| Path-based routing | Excellent | Excellent |
| TLS | Excellent | Excellent |
| OIDC / auth integration | Strong | Good to strong |
| API gateway semantics | Excellent | Good |
| Middleware / transforms | Strong | Good |
| Dynamic route onboarding | Good | Excellent |
| Ease of learning | Medium-high | Low-medium |

## Resource usage comparison

| Resource category | Gloo Gateway | Traefik |
|---|---|---|
| Memory overhead | Higher | Lower |
| CPU overhead | Higher | Lower |
| Control-plane complexity | Higher | Lower |
| Footprint with existing workloads | More noticeable | Less noticeable |
| Recommended for 8 GB / 4 vCPU nodes | Borderline | Good fit |
| Long-term scaling cost | Higher | Lower |

## Pros and cons

| Option | Pros | Cons |
|---|---|---|
| Gloo Gateway | Strong policy layer, API-centric features, good for advanced routing, strong auth/gateway semantics | More resource-intensive, more setup complexity, steeper learning curve, not ideal for small hardware-limited lab nodes |
| Traefik | Light, easy to operate, fast to add services, strong K8s integration, easier to maintain, fits local homelab scale | Less API-gateway-centric, not the best fit for advanced gateway policy-heavy platforms |

## Use cases in a homelab (real-world scenarios)

### Gloo Gateway use cases

1. Public API gateway for multiple internal services behind one auth layer.
2. A home lab exposing several service APIs under one policy boundary.
3. A platform where you want strict route policy, auth mediation, and route-level control.
4. A lab that wants to learn gateway patterns before building a larger platform.
5. A setup where you are already managing multiple internal APIs and want a centralized edge.
6. A future environment where you may add auth, observability, and gateway policies across multiple apps.
7. A service mesh-adjacent gateway design for app experimentation.
8. A multi-service platform where route-driven governance matters more than simplicity.

### Traefik use cases

1. Local ingress for Grafana, Headlamp, Keycloak, and Longhorn in a Kubernetes cluster.
2. Host-based routing for a private homelab such as grafana.vbox.local and keycloak.vbox.local.
3. Routing multiple internal web apps and dashboards behind a single ingress entrypoint.
4. Exposing Home Assistant, Jellyfin, Nextcloud, or other self-hosted services through clean local hostnames.
5. A local URL layer for a dashboard and monitoring stack without exposing each service directly.
6. A simple but scalable reverse proxy for websites and personal services on a LAN.
7. A lightweight homelab gateway for learning Kubernetes ingress without heavy API-gateway overhead.
8. A small private cloud or homelab environment where service onboarding speed and low resource use matter.

## When to use which

| Situation | Best fit |
|---|---|
| Small to medium private homelab with several apps | Traefik |
| Need a minimal but scalable ingress layer | Traefik |
| Need advanced gateway policies and API semantics | Gloo Gateway |
| Resource-constrained nodes with monitoring and storage already in use | Traefik |
| Want to build a platform-like gateway for learning and future growth | Gloo Gateway |
| Want the least operational burden in a lab environment | Traefik |

## Integration and conflict considerations with common homelab stacks

| Stack | Traefik fit | Gloo fit | Notes |
|---|---|---|---|
| Home Assistant | Excellent | Good but unnecessary | Strong host-based routing fit |
| Jellyfin / Plex / Emby | Excellent | Good but overkill | Simple hostname-based routing is ideal |
| Nextcloud / Immich | Excellent | Good | Good for app-specific routes |
| AdGuard / Pi-hole | Good | Good | Best behind dedicated hostnames and local-only access |
| Portainer / Uptime Kuma / monitoring | Excellent | Fine | Great fit for a local ingress layer |
| Keycloak | Good | Good | Best kept behind a clear hostname and auth strategy |
| Grafana / Prometheus | Excellent | Good | Works very well behind a dedicated domain/hostname |
| Longhorn | Good | Good | Usually not routed heavily, but can be exposed behind a hostname |

## Recommendation for this project

Use Traefik as the primary ingress solution for the current homelab playground.

Use Gloo only if you are intentionally moving toward a more gateway-centric and API-aware architecture, and you are comfortable with the additional control-plane and resource footprint.

This recommendation fits your current constraints:

- local-network-only environment
- modest VM memory and CPU
- existing storage/monitoring/identity/dashboard stack
- desire for safe, trusted, and widely accepted software
- interest in learning while building a real homelab

## Practical takeaway

For most private homelabs, Traefik is the better operational decision. Gloo is a valid enterprise-style option, but it is a higher-complexity solution that is more naturally suited to larger, more platform-oriented environments than a small VM-based playground cluster.
