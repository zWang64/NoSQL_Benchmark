set -e

# compile YCSB
if [ -z "$(ls -A $git_root/lib/YCSB)" ]; then
	cd $git_root/lib
    sudo git clone http://github.com/brianfrankcooper/YCSB.git >/dev/null
fi

# install python
if [ ! -n "$(python3 --version)" ]; then
    sudo apt-get install -y python3 >/dev/null
fi
if [ ! -n "$(python --version)" ]; then
    sudo apt-get install -y python >/dev/null
fi

# download java
sudo apt update
if [ -n `which java | grep 'not found'` ]; then
    sudo apt install -y openjdk-14-jdk >/dev/null
fi

# download maven
if [ -n `which maven | grep 'not found'`]; then
    sudo apt install -y maven >/dev/null
fi
