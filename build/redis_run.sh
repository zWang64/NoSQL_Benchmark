#export git_root=$(git rev-parse --show-toplevel)

echo "git_root=$git_root"

# clean up redis content if this script fails
cleanup() {
    echo "Cleaning up redis..."
    redis-cli flushall
    echo "done"
}
trap cleanup EXIT

if [ -n "$1" ]; then
    source $git_root/cluster/cluster.conf

    # create redis cluster
    #redis-cli --cluster create $node1_ip:6379 $node2_ip:6379 $node3_ip:6379 $node4_ip:6379 $node5_ip:6379 $node6_ip:6379 --cluster-replicas 1
    echo "try create cluster"
    redis-cli --cluster create $node1_ip:6379 $node2_ip:6379 $node3_ip:6379 --cluster-replicas 0 
    echo "nodes: $node1_ip, $node2_ip, $node3_ip"
    echo "cluster created"
else
    master_ip="127.0.0.1"
fi

# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo $git_root/lib/YCSB/bin/ycsb load redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 -p redis.cluster=true | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 -p redis.cluster=true | sudo tee $out_path/outputRun.txt

# clean up
# note in cluster mode, you need to manually clean up all records in all nodes.
redis-cli flushall
