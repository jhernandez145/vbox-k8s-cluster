# Utility Scripts

This folder contains small bash helpers for common administrative tasks in the VirtualBox Kubernetes lab.

## Overview

These utilities are designed to make local access to cluster services easier when your browser is not on the same bridged network as the VirtualBox VMs.

## Scripts

### generate-ssh-tunnel-command.sh
Purpose: Build a ready-to-run SSH tunnel command for local access to the cluster services.

Usage:
```bash
./utils/generate-ssh-tunnel-command.sh
```

Example output:
```bash
ssh -L 3000:192.168.102.203:80 -L 8080:192.168.102.204:80 -L 8081:192.168.102.202:80 -L 8082:192.168.102.200:80 master@node-master

Local endpoints:
  Grafana   -> http://localhost:3000
  Keycloak  -> http://localhost:8080
  Longhorn  -> http://localhost:8081
  Headlamp  -> http://localhost:8082
```

### show-service-ips.sh
Purpose: Print the current LoadBalancer IPs for the core cluster services.

Usage:
```bash
./utils/show-service-ips.sh
```

Example output:
```bash
grafana:  192.168.102.203
headlamp: 192.168.102.200
keycloak: 192.168.102.204
longhorn: 192.168.102.202
```

### list-local-service-urls.sh
Purpose: Print the localhost URLs you can open after SSH tunneling is active.

Usage:
```bash
./utils/list-local-service-urls.sh
```

Example output:
```bash
Grafana:   http://localhost:3000
Keycloak:  http://localhost:8080
Longhorn:  http://localhost:8081
Headlamp:  http://localhost:8082
```

### create-headlamp-token.sh
Purpose: Create the Headlamp admin service account and print a token for login.

Usage:
```bash
./utils/create-headlamp-token.sh
```

Example output:
```bash
eyJhbGciOiJSUzI1NiIsImtpZCI6IlBqZldBd2p5cGFrM2UtZnRfc2VhdGstVHFkX1NyVWowaTYzeXp2eEIyX1kifQ...
```

## Access note

Use the SSH tunnel pattern when your browser is not on the same bridged LAN as the VM, or when the service is exposed only through a private 192.168.x.x address. Direct access to the bridged IP works only when the browser machine can actually reach that network segment. The tunnel keeps the Cilium load balancer in place while creating a reliable local route to the services.
