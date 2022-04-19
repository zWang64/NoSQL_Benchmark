set -e

# compile YCSB
if [ -z "$(ls -A $git_root/lib/YCSB)" ]; then
    echo "Installig YCSB..."
    cd $git_root/lib
    sudo git clone http://github.com/brianfrankcooper/YCSB.git >/dev/null
fi

# install python
if [ ! -n "$(python3 --version)" ]; then
    echo "Installing python3..."
    sudo apt-get install -y python3 >/dev/null
fi
if [ ! -n "$(python --version)" ]; then
    echo "Installing python2..."
    sudo apt-get install -y python >/dev/null
fi

# download java
sudo apt update >/dev/null
if [ ! -n `which java | grep 'not found'` ]; then
    echo "Installing Java..."
    sudo apt install -y default-jre >/dev/null
fi

# download maven
if [ ! -n `which maven | grep 'not found'`]; then
    echo "Installing Maven..."
    sudo apt install -y maven >/dev/null
fi
