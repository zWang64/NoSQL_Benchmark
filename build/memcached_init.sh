# download memcached if not exist
if [ ! -n "$(memcached -V)" ]; then
     sudo apt-get update
     sudo apt-get install -y memcached
fi
