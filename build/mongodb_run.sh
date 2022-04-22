sudo service mongod stop
sudo apt-get -y purge mongodb-org*
sudo rm -r /var/log/mongodb /var/lib/mongodb

bash $git_root/build/mongodb_init.sh

echo "Restart finish."

sudo $git_root/lib/YCSB/bin/ycsb load mongodb -s -P $workload -p recordcount=$count -threads 10 | sudo tee $out_path/outputLoad.txt

# run tests
echo "running mongo bm"
echo "thread count = 10"
sudo $git_root/lib/YCSB/bin/ycsb run mongodb -s -P $workload -p recordcount=$count -p operationcount=$(($count)) -threads 10 -jvm-args="-Dlogback.configurationFile=/path/to/logback.xml" | sudo tee $out_path/outputRun.txt
