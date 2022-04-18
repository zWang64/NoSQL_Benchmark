export git_root=$(git rev-parse --show-toplevel)

# compile YCSB
if [ ! -z "$git_root/lib/YCSB" ]; then
        cd $git_root/lib
        sudo git clone http://github.com/brianfrankcooper/YCSB.git
fi
