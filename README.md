# scale-testing
Setting up containerized pbench, collectd and running benchmarks

### Clone the repo
```
$ git clone https://github.com/chaitanyaenr/scale-testing.git /root/scale-testing
```

### Label the nodes with a type=pbench label
```   
$ oc label node <node> type=pbench
```

### create a service account and add it to the privileged scc
```
$ oc create serviceaccount useroot
$ oc adm policy add-scc-to-user privileged -z useroot
```

### create pbench-agent pods and patch it
```
$ oc create -f /root/scale-testing/openshift-templates/pbench-agent-daemonset.yml
$ oc patch daemonset pbench-agent --patch \ '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
```

### create a configmap to feed credentials to the collectd pod
```
$ oc create -f /root/scale-testing/openshift-templates/collectd-config.yml
```

### create collectd pods and patch it
```
$ oc create -f /root/scale-testing/openshift-templates/collectd-daemonset.yml
$ oc patch daemonset collectd --patch \ '{"spec":{"template":{"spec":{"serviceAccountName": "useroot"}}}}'
```
   
## Prepare the jump host to run pbench-controller

### Get the controller image from dockerhub
```
$ docker pull ravielluri/image:controller
$ docker tag ravielluri/image:controller pbench-controller:latest
```

### keys
copy the ssh keys to /root/scale-testing/keys. The keys directory should contain a perf key named as id_rsa_perf,  id_rsa - the private key needed to copy the results to the pbench server, authorized_keys file -ansible needs to have a passwordless authentication to localhost inside the container, ssh config which looks like:
```
Host *
	User root
        Port 2022
        StrictHostKeyChecking no
        PasswordAuthentication no
        UserKnownHostsFile ~/.ssh/known_hosts
        IdentityFile ~/.ssh/id_rsa_perf  
      
Host *pbench-server
        User root
        Port 22
        StrictHostKeyChecking no
        PasswordAuthentication no
        UserKnownHostsFile ~/.ssh/known_hosts
        IdentityFile /opt/pbench-agent/id_rsa
```
### Inventory
Make sure you have the inventory used to install openshift and it should look like:
```
[pbench-controller]

[masters]
    
[nodes]

[etcd]

[lb]

[prometheus-metrics]
<host> port=8443 cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key
<host> port=10250 cert=/etc/origin/master/admin.crt key=/etc/origin/master/admin.key

[pbench-controller:vars]
register_all_nodes=False
```

Set register_all_nodes to true if the tools needs to be registered on all the nodes, if not set to true, it registers pbench tools on just two of the nodes.

NOTE: 
- Make sure all the variables are defined under [group:vars], all the stuff under [groups] are assumed to be the node ip’s.

- In HA environment, we will have an lb which is not an openshift node. This means that there won’t be a pbench-agent pod running on the lb, pbench-ansible will fail registering tools as it won’t find a pbench-agent pod. So, we need to make a copy of the original inventory and get rid of the lb node from the inventory which is being mounted into the container.
  
- We need to make sure we stick to either ip’s or hostnames in both inventory and openshift for certificates to be valid.

## Run benchmarks
Edit the vars file and set benchmark_type variable to the benchmark that you want to run, pbench_server - host where the results are moved, move_results to True. 

### Avalaible benchmark_type options:
- nodeVertical
- http
- masterVertical

### Results
If the move_results is set to True, the results are moved to the pbench server. In case you want to look at the results before moving, set move_results to False and the results will be available at /root/scale-testing/results which is mounted to the pbench-controller container.

### Monitoring the benchmark
You can monitor what's going inside the container using the following command
```
$ docker logs -f controller
```
You should be able to see the pbench-ansible registering tools and the benchmark stdout. The following message is displayed once the container is done with the benchmark:
```
-----------------------------------------------------------
	OCP SCALE TEST COMPLETED
-----------------------------------------------------------
```
In case the benchmark fails, the following message is displayed:
```
-----------------------------------------------------------
        OCP SCALE TEST FAILED
-----------------------------------------------------------
```
