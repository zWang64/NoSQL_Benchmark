export git_root=$(git rev-parse --show-toplevel)

# download redis if not exist
if [ ! -n "$(redis-cli -v)" ]; then
	echo "Download redis..."
	curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
	echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
	sudo apt-get update
	sudo apt-get install -y redis
fi

# start redis service
cd $git_root/lib/redis && redis-server --daemonize yes &> /dev/null
echo "Redis is started."
