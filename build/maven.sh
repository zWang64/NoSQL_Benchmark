# download java
sudo apt update 
if [ -n `which java | grep 'not found'` ]; then
	sudo apt install -y openjdk-14-jdk	
fi
java -version
# download maven
if [ -n `which maven | grep 'not found'`]; then
	sudo apt install -y maven
fi
mvn -version
