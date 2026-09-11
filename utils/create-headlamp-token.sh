#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Usage: $0"
  echo "Creates the Headlamp admin service account and prints a token for login."
  exit 0
fi

kubectl create serviceaccount headlamp-admin -n headlamp --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl create clusterrolebinding headlamp-admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=headlamp:headlamp-admin \
  --dry-run=client -o yaml | kubectl apply -f - >/dev/null

kubectl -n headlamp create token headlamp-admin
