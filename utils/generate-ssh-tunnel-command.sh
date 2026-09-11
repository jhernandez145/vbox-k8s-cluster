#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 [ssh-user] [ssh-host]"
  echo "Example: $0 master node-master"
  echo "Example: $0 your-user 192.168.1.50"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

SSH_USER="${1:-$(whoami)}"
SSH_HOST="${2:-node-master}"

require_kubectl() {
  if ! command -v kubectl >/dev/null 2>&1; then
    echo "Error: kubectl is not installed or not in PATH." >&2
    exit 1
  fi
}

get_lb_ip() {
  local namespace="$1"
  local service_name="$2"

  kubectl get svc -n "$namespace" "$service_name" \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true
}

require_kubectl

GRAFANA_IP="$(get_lb_ip monitoring monitoring-grafana)"
KEYCLOAK_IP="$(get_lb_ip identity keycloak-keycloak-chart-http)"
LONGHORN_IP="$(get_lb_ip longhorn-system longhorn-frontend)"
HEADLAMP_IP="$(get_lb_ip headlamp headlamp)"

if [[ -z "$GRAFANA_IP" || -z "$KEYCLOAK_IP" || -z "$LONGHORN_IP" || -z "$HEADLAMP_IP" ]]; then
  echo "Error: one or more LoadBalancer IPs were not found. Verify the services are running:" >&2
  echo "  kubectl get svc -A" >&2
  exit 1
fi

cmd=(ssh)
cmd+=(-L "3000:${GRAFANA_IP}:80")
cmd+=(-L "8080:${KEYCLOAK_IP}:80")
cmd+=(-L "8081:${LONGHORN_IP}:80")
cmd+=(-L "8082:${HEADLAMP_IP}:80")
cmd+=("${SSH_USER}@${SSH_HOST}")

printf '%s ' "${cmd[@]}"
printf '\n\n'

echo "Local endpoints:"
echo "  Grafana   -> http://localhost:3000"
echo "  Keycloak  -> http://localhost:8080"
echo "  Longhorn  -> http://localhost:8081"
echo "  Headlamp  -> http://localhost:8082"
