# Prometheus & Grafana Monitoring Infrastructure (OCI Edition)

Provides real-time metric scraping and visual performance analytics across all VirtualBox cluster nodes using official upstream OCI artifacts.

## 🚀 Installation & First Boot
No repository mapping required. Deploy directly from the container registry:
```bash
# Ensure the tracking namespace exists
kubectl create namespace monitoring

# Install directly from GitHub Container Registry (GHCR) over OCI
helm install monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 90.0.0 \
  --namespace monitoring \
  --values monitoring-values.yaml
```

## 🔄 Upgrading Configurations
```bash
helm upgrade monitoring oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack \
  --version 90.0.0 \
  --namespace monitoring \
  --values monitoring-values.yaml
```

## 🛠️ Usage & Verification
*   **Track Control Plane**: `kubectl get pods -n monitoring`
*   **View Dashboards UI**: `kubectl get svc -n monitoring | grep grafana` (Access via `http://192.168.102.202`)

## Post-install Notes
```
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring"

Get Grafana 'admin' user password by running:

  kubectl --namespace monitoring get secrets monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

Access Grafana local instance:

  export POD_NAME=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=monitoring" -oname)
  kubectl --namespace monitoring port-forward $POD_NAME 3000

Get your grafana admin user password by running:

  kubectl get secret --namespace monitoring -l app.kubernetes.io/component=admin-secret -o jsonpath="{.items[0].data.admin-password}" | base64 --decode ; echo


Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```
