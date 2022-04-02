bash ./init.sh

export git_root=$(git rev-parse --show-toplevel)

# download redis if not exist
if [ ! -n "$(redis-cli -v)" ]; then
	curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
	sudo apt-get update
	sudo apt-get install -y redis
fi

# start redis service
if [ ! -n `redis-cli ping | grep 'PONG'` ]; then
	cd $git_root/lib/redis && redis-server &
fi

cd $git_root/lib/YCSB
bash $git_root/build/maven.sh
sudo mvn -e -pl site.ycsb:redis-binding -am clean package

# setup output path
out_path=$git_root/out/redis
sudo mkdir -p $out_path

bash $git_root/build/python.sh

# set config
#       *set the cluster parameter to true if redis cluster mode is enabled. Default is false.
sudo ./bin/ycsb load redis -s -P workloads/workloada -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputLoad.txt

# run tests
sudo ./bin/ycsb run redis -s -P workloads/workloada -p redis.host=127.0.0.1 -p redis.port=6379 | sudo tee $out_path/outputRun.txt
