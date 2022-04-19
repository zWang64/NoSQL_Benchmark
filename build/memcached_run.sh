# load data
sudo $git_root/lib/YCSB/bin/ycsb load memcached -s -P $workload -p recordcount=$count -p memcached.hosts=127.0.0.1 | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run memcached -s -P $workload -p recordcount=$count -p memcached.hosts=127.0.0.1 | sudo tee $out_path/outputRun.txt
