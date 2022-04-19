# download memcached if not exist
if [ ! -n "$(memcached -V)" ]; then
     sudo apt-get update > /dev/null
     sudo apt-get install -y memcached > /dev/null
fi
