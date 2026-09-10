Folder structure:

```
vbox-k8s-cluster/
├── cluster-init/                # Scripts or notes on how you ran kubeadm init
├── infrastructure/              # Core cluster utilities (Layer 4-7)
│   ├── cilium/                  # Cilium configs (values.yaml, IPPool, L2Policy)
│   └── ingress-nginx/           # Future ingress controllers
└── apps/                        # Your actual container applications
    └── test-web/                # Nginx test deployment manifests
```
