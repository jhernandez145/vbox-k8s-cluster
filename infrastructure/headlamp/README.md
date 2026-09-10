# Headlamp Graphical Dashboard Cockpit

An extensible visual interface to view, troubleshoot, and interactively manage cluster deployments directly from your physical host computer.

## 🚀 Installation & First Boot
Create the dedicated monitoring space and deploy via Helm:
```bash
helm repo add headlamp https://github.io
helm repo update
helm install headlamp headlamp/headlamp \
  --namespace headlamp \
  --create-namespace \
  --values headlamp-values.yaml
```

## 🔄 Upgrading Configurations
To update UI properties or scale parameters safely, flush the historical chart release tracking objects completely:
```bash
helm uninstall headlamp --namespace headlamp
kubectl delete namespace headlamp --grace-period=0 --force
helm install headlamp headlamp/headlamp \
  --namespace headlamp \
  --create-namespace \
  --values headlamp-values.yaml
```

## 🛠️ Usage & Login Authentication
1.  **Find External Endpoint**: `kubectl get svc -n headlamp` (Access via `http://192.168.102.200`)
2.  **Generate Secure Admin Token**:
    ```bash
    kubectl create serviceaccount headlamp-admin -n headlamp
    kubectl create clusterrolebinding headlamp-admin-binding --clusterrole=cluster-admin --serviceaccount=headlamp:headlamp-admin
    kubectl -n headlamp create token headlamp-admin
    ```
3.  Copy the output string and paste it into the web login portal prompt box.
