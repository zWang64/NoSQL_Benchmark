# clean up redis content if this script fails
function cleanup {
    echo "Cleaning up redis..."
    redis-cli flushall
    echo "done"
}
trap cleanup EXIT

# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo $git_root/lib/YCSB/bin/ycsb load redis -s -P $workload_clz -p recordcount=$count -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run redis -s -P $workload_clz -p recordcount=$count -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputRun.txt

# clean up
redis-cli flushall
