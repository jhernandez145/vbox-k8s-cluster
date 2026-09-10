# Longhorn Distributed Block Storage Array

Provides fault-tolerant, resilient data architectures by transparently replicating synchronous disk volume blocks across independent VirtualBox worker nodes.

## 🚀 Installation & First Boot
1.  **OS Prerequisites** (Execute on **ALL** master and worker VMs via SSH):
    ```bash
    sudo apt-get update && sudo apt-get install -y open-iscsi nfs-common
    sudo systemctl enable --now iscsid
    ```
2.  **Deploy via Master Control Plane**:
    ```bash
    helm repo add longhorn https://longhorn.io
    helm repo update
    helm install longhorn longhorn/longhorn \
      --namespace longhorn-system \
      --create-namespace \
      --values longhorn-values.yaml
    ```

## 🔄 Upgrading Configurations
Modify storage replicas or settings inside `longhorn-values.yaml` and re-apply using modern UI chart context overrides:
```bash
helm upgrade longhorn longhorn/longhorn \
  --namespace longhorn-system \
  --reset-values \
  --values longhorn-values.yaml
```

## 🛠️ Usage & Operations Verification
*   **Track Control Plane Health**: `kubectl get pods -n longhorn-system`
*   **View Web Monitor Console**: `kubectl get svc -n longhorn-system longhorn-frontend` (Typically mapped to `http://192.168.102.201`)
*   **Set as Cluster Default Storage Engine**:
    ```bash
    kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
    kubectl patch storageclass longhorn -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
    ```
