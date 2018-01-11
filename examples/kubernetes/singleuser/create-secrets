#!/bin/sh
KUBE_NAMESPACE="default"
cd `dirname $0`
for file in *.secrets
do
  basename="$(basename $file)"
  kubectl create secret generic "${basename%.*}" --namespace="$KUBE_NAMESPACE" --from-env-file="$file" -o yaml --dry-run | tee "${basename%.*}.yml" | kubectl apply -f -
done
