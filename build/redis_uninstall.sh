export git_root=$(git rev-parse --show-toplevel)

bash $git_root/build/redis_stop.sh

sudo apt-get purge --auto-remove redis-server
