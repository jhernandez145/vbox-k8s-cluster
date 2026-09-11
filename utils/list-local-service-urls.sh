#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: $0"
  echo "Prints the local URLs to access services through SSH tunnels."
  exit 0
fi

echo "Grafana:   http://localhost:3000"
echo "Keycloak:  http://localhost:8080"
echo "Longhorn:  http://localhost:8081"
echo "Headlamp:  http://localhost:8082"
