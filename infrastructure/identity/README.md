## Post-installation Notes:
===============================================================================
 🐳  KEYCLOAK-CHART  —  A Docker Hardened Helm Chart
===============================================================================

This is a keycloak-chart Docker Helm chart built from the Upstream Official Project
keycloak-chart Helm chart while using a hardened configuration with
**Docker Hardened Images**.

To learn more about how to use this Helm chart, visit the upstream documentation:
https://dhi.io
===============================================================================

⭐ KEYCLOAK-CHART has been deployed!

Release:      keycloak
Namespace:    identity
Chart:        keycloak-chart 7.3.1
App version:  26.7.3

Keycloak was installed with a Service of type LoadBalancer

NOTE: It may take a few minutes for the LoadBalancer IP to be available.
     You can watch the status of by running 'kubectl get --namespace identity service -w keycloak-keycloak-chart'

Get its HTTP URL with the following commands:

export SERVICE_IP=$(kubectl get service --namespace identity keycloak-keycloak-chart-http --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "http://$SERVICE_IP:80"

Get its HTTPS URL with the following commands:

export SERVICE_IP=$(kubectl get service --namespace identity keycloak-keycloak-chart-http --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo "http://$SERVICE_IP:8443"


ℹ️ Checkout the getting started guides at: https://dhi.io

🧹 Uninstall
$ helm -n identity uninstall keycloak
===============================================================================
