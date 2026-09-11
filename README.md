# VirtualBox Headless Kubernetes Lab Cluster

A bare-metal Kubernetes development sandbox engineered on Ubuntu Server VMs inside Oracle VirtualBox. It utilizes advanced eBPF networking, Layer 2 load balancing, and distributed block storage replication.

## 📁 Repository File Structure

```text
~/vbox-k8s-cluster/
├── README.md                           # Main cluster documentation
├── utils/
│   ├── generate-ssh-tunnel-command.sh  # Build the SSH tunnel command for local access
│   ├── show-service-ips.sh             # Print current external service IPs
│   └── list-local-service-urls.sh      # Print the local URLs behind the tunnel
└── infrastructure/
    ├── cilium/
    │   ├── README.md                   # Networking & Load Balancing info
    │   └── cilium-values.yaml          # Cilium Helm configurations
    ├── headlamp/
    │   ├── README.md                   # Web Management UI info
    │   └── headlamp-values.yaml        # Headlamp Helm configurations
    └── longhorn/
        ├── README.md                   # Distributed Storage info
        └── longhorn-values.yaml        # Longhorn Helm configurations
```

---

## 🔧 Utility Scripts

A set of bash helpers for accessing the cluster services locally is available in [utils/README.md](utils/README.md).

This includes helpers to:
- [generate the SSH tunnel command](utils/generate-ssh-tunnel-command.sh)
- [print the current service IPs](utils/show-service-ips.sh)
- [list the local URLs behind the tunnel](utils/list-local-service-urls.sh)
- [create a Headlamp admin token](utils/create-headlamp-token.sh)

See [utils/README.md](utils/README.md) for purpose, usage, and sample output for each script.

---

## 📘 Appendix / Acronym Dictionary

*   **ARP**: Address Resolution Protocol. Used by Cilium L2 announcements to claim IP traffic on local Host-Only subnets without an upstream router.
*   **CSI**: Container Storage Interface. The standard API specification enabling Kubernetes to provision and manage persistent underlying disk storage volume drivers.
*   **eBPF**: Extended Berkeley Packet Filter. A kernel technology allowing programs to run sandboxed code inside the Linux kernel without changing kernel source code or loading modules, used here for ultra-fast networking.
*   **IPAM**: IP Address Management. The system engine that calculates, assigns, and tracks internal pod networks and external LoadBalancer IP addresses.
*   **iSCSI**: Internet Small Computer Systems Interface. A protocol used by Longhorn to map raw block storage devices over the local network to active cluster pods.
*   **PV / PVC**: PersistentVolume / PersistentVolumeClaim. A PV is an actual cluster disk storage resource block. A PVC is an application's matching ticket requesting a slice of that storage.
*   **VXLAN**: Virtual Extensible LAN. An encapsulation protocol used to create an overlay tunnel network, enabling pods on different VMs to communicate securely.
*   **GHCR**: GitHub Container Registry. A cloud platform used to host container images and OCI-compliant Helm chart packages securely.
*   **OCI**: Open Container Initiative. A governance structure that standardizes container formats and runtimes, allowing Helm charts to be stored and pulled exactly like standard Docker container images.
