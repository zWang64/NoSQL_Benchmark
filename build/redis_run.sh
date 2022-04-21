#export git_root=$(git rev-parse --show-toplevel)

echo "git_root=$git_root"
# clean up redis content if this script fails
cleanup() {
    echo "Cleaning up redis..."
    if [ "$cluster_mode" == "true" ]; then
        echo "send FLUSHALL to cluster..."
        redis-cli -h $node1_ip -p 6379 flushall
	redis-cli -h $node2_ip -p 6379 flushall
	redis-cli -h $node3_ip -p 6379 flushall
	echo "send CLUSTER RESET to cluster..."
	redis-cli -h $node1_ip -p 6379 CLUSTER RESET 
        redis-cli -h $node2_ip -p 6379 CLUSTER RESET
        redis-cli -h $node3_ip -p 6379 CLUSTER RESET
    else
    	redis-cli flushall
    fi
    echo "done"
}
trap cleanup EXIT

export cluster_mode="false"
if [ -n "$1" ]; then
    export cluster_mode="true"
    
    source $git_root/cluster/cluster.conf

    # create redis cluster
    #redis-cli --cluster create $node1_ip:6379 $node2_ip:6379 $node3_ip:6379 $node4_ip:6379 $node5_ip:6379 $node6_ip:6379 --cluster-replicas 1
    echo "try create cluster"
    redis-cli --cluster create $node1_ip:6379 $node2_ip:6379 $node3_ip:6379 --cluster-replicas 0 --cluster-yes
    echo "nodes: $node1_ip, $node2_ip, $node3_ip"
    echo "cluster created"
else
    master_ip="127.0.0.1"
fi

# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo $git_root/lib/YCSB/bin/ycsb load redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 -p redis.cluster=$cluster_mode -threads 10 | sudo tee $out_path/outputLoad.txt

# run tests
echo "running redis bm"
echo "thread count = 10"
sudo $git_root/lib/YCSB/bin/ycsb run redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 -p redis.cluster=$cluster_mode -p operationcount=$(($count)) -threads 10 | sudo tee $out_path/outputRun.txt
