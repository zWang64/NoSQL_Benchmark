export git_root=$(git rev-parse --show-toplevel)

# compile YCSB
if [ -z "$(ls -A $git_root/lib/YCSB)" ]; then
        echo "Installing YCSB..."
	cd $git_root/lib
        sudo git clone http://github.com/brianfrankcooper/YCSB.git
	echo "done."
fi
