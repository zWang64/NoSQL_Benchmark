export git_root=$(git rev-parse --show-toplevel)
export test_name=$1

bash $git_root/build/init.sh

# download memcached if not exist
if [ ! -n "$(memcached -V)" ]; then
	sudo apt-get update
	sudo apt-get install -y memcached
fi

cd $git_root/lib/YCSB
bash $git_root/build/maven.sh
sudo mvn -e -pl site.ycsb:memcached-binding -am clean package

# setup output path
out_path=$git_root/out/$test_name/memcached
sudo mkdir -p $out_path

bash $git_root/build/python.sh

# load data
sudo $git_root/lib/YCSB/bin/ycsb load memcached -s -P workloads/workloada -p memcached.hosts=127.0.0.1 | sudo tee $out_path/outputLoad.txt

# run tests
sudo $git_root/lib/YCSB/bin/ycsb run memcached -s -P workloads/workloada -p memcached.hosts=127.0.0.1 | sudo tee $out_path/outputRun.txt
