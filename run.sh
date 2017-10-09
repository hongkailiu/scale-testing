#!/bin/sh

files_dir=/root/scale-testing
docker run -t -d --name=controller --net=host --privileged \
    -v $files_dir/results:/var/lib/pbench-agent \
    -v $files_dir/inventory:/root/inventory \
    -v $files_dir/vars:/root/vars \
    -v $files_dir/keys:/root/.ssh \
    -v $files_dir/benchmark.sh:/root/benchmark.sh pbench-controller
