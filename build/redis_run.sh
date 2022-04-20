export git_root=$(git rev-parse --show-toplevel)

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
    redis-cli --cluster create $node1_ip:$redis_cluster_port $node2_ip:$redis_cluster_port $node3_ip:$redis_cluster_port --cluster-replicas 0 
else
    master_ip="127.0.0.1"
    
# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo $git_root/lib/YCSB/bin/ycsb load redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run redis -s -P $workload -p recordcount=$count -p redis.host=$master_ip -p redis.port=6379 | sudo tee $out_path/outputRun.txt

# clean up
# note in cluster mode, you need to manually clean up all records in all nodes.
redis-cli flushall
