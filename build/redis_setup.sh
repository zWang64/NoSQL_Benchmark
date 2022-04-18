# program exits after the first line that fails
set -e

# git repo root path
export git_root=$(git rev-parse --show-toplevel)

bash $git_root/build/init.sh

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

bash $git_root/build/python.sh