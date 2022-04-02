if [ ! -n "$(python3 --version)" ]; then
	sudo apt-get install -y python3
fi
if [ ! -n "$(python --version)" ]; then
	sudo apt-get install -y python
fi
