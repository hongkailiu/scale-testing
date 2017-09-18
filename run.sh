#!/bin/sh

files_dir=/root/scale-testing
docker run -t -d --net=host --privileged \
    -v $files_dir/results:/var/lib/pbench-agent \
    -v $files_dir/hosts-openshift.inv:/root/inventory \
    -v $files_dir/vars:/root/vars \
    -v $files_dir/keys:/root/.ssh \
    -v $files_dir/benchmark.sh:/root/benchmark.sh \
    -v $files_dir/stress-mb.yaml:/root/svt/openshift_scalability/config/stress-mb.yaml \
    -v $files_dir/stress-pod.json:/root/svt/openshift_scalability/content/quickstarts/stress/stress-pod.json pbench-controller
