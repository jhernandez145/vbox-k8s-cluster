#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: $0"
  echo "Displays the current external LoadBalancer IPs for the core cluster services."
  exit 0
fi

kubectl get svc -A \
  --no-headers \
  | awk '
    $1 == "headlamp" { print "headlamp: ",$5 }
    $1 == "identity" && $2 ~ /^keycloak-keycloak-chart-http$/ { print "keycloak: ",$5 }
    $1 == "longhorn-system" && $2 ~ /^longhorn-frontend$/ { print "longhorn: ",$5 }
    $1 == "monitoring" && $2 ~ /^monitoring-grafana$/ { print "grafana: ",$5 }
  ' \
  | sort
