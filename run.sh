#!/bin/bash

# wrap cluster loader commands with pbench
cd /root/svt/openshift_scalability
export KUBECONFIG=/root/.kube/config
if [[ "${benchmark_type}" == "nodeVertical" || "{{benchmark_type}" == "nodevertical" ]]; then
        ./cluster-loader.py -avf config/nodeVertical.yaml
fi
if [[ "${benchmark_type}" == "http" ]]; then
        ./cluster-loader.py -vaf config/stress-mb.yaml
fi
