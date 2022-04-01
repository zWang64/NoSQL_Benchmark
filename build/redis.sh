# check if the git_root is set
if [ ! -n $git_root ]; then
	echo "run 'source init.bash' first"
	exit 1
fi

# download redis if not exist
if [ ! -n `which redis`]; then
	curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
	sudo apt-get update
	sudo apt-get install -y redis
fi

# start redis service
if [ ! -n `redis-cli ping | grep 'PONG'` ]; then
	cd $git_root/lib/redis && redis-server &
fi

# compile YCSB
if [ ! -d $git_root/lib/YCSB ]; then
	cd $git_root/lib
	git clone http://github.com/brianfrankcooper/YCSB.git
fi
cd $git_root/lib/YCSB
mvn -pl site.ycsb:redis-binding -am clean package

# setup output path
out_path=$git_root/lib/redis/out
mkdir -p $out_path 

# set config
# 	*set the cluster parameter to true if redis cluster mode is enabled. Default is false.
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=127.0.0.1" -p "redis.port=6379" > $out_path/outputLoad.txt

# load the data and run tests
./bin/ycsb load redis -s -P workloads/workloada > $out_path/outputLoad.txt
./bin/ycsb run redis -s -P workloads/workloada > $out_path/outputRun.txt
