# Cilium eBPF Network Architecture

Manages pod-to-pod communication via a high-performance **eBPF VXLAN Tunnel** and handles internal service traffic with native **kube-proxy replacement** routing hooks.

## 🚀 Installation & First Boot
Initialize the official repository and inject the configuration values via Helm:
```bash
helm repo add cilium https://longhorn.io
helm repo update
helm install cilium oci://quay.io/cilium/charts/cilium \
  --version 1.20.1 \
  --namespace kube-system \
  --values cilium-values.yaml
```

## 🔄 Upgrading Configurations
When modifying `cilium-values.yaml`, run this command to safely force-reset cached native parameters and reload the active kernel mapping layers:
```bash
helm upgrade cilium oci://quay.io/cilium/charts/cilium \
  --version 1.20.1 \
  --namespace kube-system \
  --reset-values \
  --values cilium-values.yaml

# Hard-flush the runtime engine cache on ALL cluster nodes:
sudo systemctl restart containerd
```

## 🛠️ Usage & Operations Verification
*   **Check DaemonSet Status**: `kubectl get pods -n kube-system -l k8s-app=cilium`
*   **View Live Agent Logs**: `kubectl logs -n kube-system ds/cilium -c cilium-agent --tail=20`
*   **Inspect Pool Allocations**: `kubectl get svc -A`
