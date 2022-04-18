# exit after first line that fails
set -e

function cleanup {
    echo "Cleaning up redis..."
    redis-cli flushall
    echo "done"
}

# clean up redis content if this script fails
trap cleanup EXIT

export git_root=$(git rev-parse --show-toplevel)

# command line input, example:
#     bash ./redis_run.sh a 300000
if [ -n "$1" ]; then
    workload_clz="workloads/workload$1"
else
    workload_clz="workloads/workloada"
fi
echo "using workload: $workload_clz"

if [ -n "$2" ]; then
    count=$2
else
    count=1000
fi
echo "using record count: $count"

# run maven project
echo "building YCSB..."
cd $git_root/lib/YCSB
bash $git_root/build/maven.sh 
echo "building redis binding..."
sudo mvn -e -pl site.ycsb:redis-binding -am clean package >/dev/null
echo "done."

# setup output path
out_path=$git_root/out/redis
sudo mkdir -p $out_path

# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo $git_root/lib/YCSB/bin/ycsb load redis -s -P $workload_clz -p recordcount=$count -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run redis -s -P $workload_clz -p recordcount=$count -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputRun.txt

# clean up
redis-cli flushall
