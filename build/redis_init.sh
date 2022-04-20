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
cd $git_root/lib/redis
if [ -n "$1" ]; then
    echo "start redis in cluster mode"
    # allow incoming traffic
    sudo ufw allow 6379
    sudo ufw allow 6379/tcp
    sudo ufw allow 16379
    sudo ufw allow 16379/tcp
    
    redis-server ./redis.conf --daemonize yes 
else
    echo "start redis in stand alone mode"
    echo "this is mainly used for test"
    redis-server --daemonize yes &> /dev/null
fi
echo "Redis is started."
