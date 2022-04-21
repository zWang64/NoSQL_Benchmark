echo "git_root=$git_root"

ycsb_root=$git_root/lib/YCSB

sudo $ycsb_root/bin/ycsb load rocksdb -s -P $workload -p recordcount=$count -p rocksdb.dir=/tmp/ycsb-rocksdb-data -threads 10 | sudo tee $out_path/outputLoad.txt

sudo $ycsb_root/bin/ycsb run rocksdb -s -P $workload -p recordcount=$count -p rocksdb.dir=/tmp/ycsb-rocksdb-data -p operationcount=$(($count)) -threads 10 | sudo tee $out_path/outputLoad.txt
