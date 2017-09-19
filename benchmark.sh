#!/bin/bash

# wrap cluster loader commands with pbench
cd /root/svt/openshift_scalability

# nodeVertical
if [[ "${benchmark_type}" == "nodeVertical" || "{{benchmark_type}" == "nodevertical" ]]; then
	pbench-user-benchmark -C nodeVert -- ./nodeVertical.sh nodeVert
        #./cluster-loader.py -avf config/nodeVertical.yaml
# http
elif [[ "${benchmark_type}" == "http" ]]; then
	# pbench-user-benchmark -C http -- ./http_test.sh
        ./cluster-loader.py -vaf config/stress-mb.yaml
#master-Vertical
elif [[ "${benchmark_type}" == "masterVertical" ]] || [[ "{benchmark_type}" == "mastervertical" ]]; then
	# pbench-user-benchmark -C masterVert -- ./masterVertical.sh
	./masterVertical.sh
fi
