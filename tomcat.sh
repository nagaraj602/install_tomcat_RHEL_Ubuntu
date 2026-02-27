#!/bin/bash

path=$(pwd)

distro=$(cat /etc/os-release | grep "^ID=" | cut -d "=" -f2 | sed 's/"//g')

echo "Initiating Tomcat Installation."
echo "Please enter the port number (use between 2 and 65535):"
read port

echo -e "\nThank you for selecting port: $port \n\n\nInstalling Tomcat 11 with Java OpenJDK 25 on $distro..."

sudo systemctl stop tomcat 2>/dev/null

if id tomcat &>/dev/null || [ -d /opt/tomcat ]; then
    sudo systemctl disable tomcat 2>/dev/null
    sudo rm -rf /opt/tomcat
    sudo userdel -r tomcat 2>/dev/null
    sudo groupdel tomcat 2>/dev/null
    sudo rm -f /etc/systemd/system/tomcat.service
    sudo systemctl daemon-reload
fi

if [ "$distro" = "rhel" ]; then
    sudo yum update -y > /dev/null
    sudo yum install wget curl java-25-openjdk-devel -y > /dev/null
elif [ "$distro" = "ubuntu" ]; then
    sudo apt update -y > /dev/null
    sudo apt install wget curl openjdk-25-jdk -y > /dev/null
else
    echo "Unsupported Distribution - Only RHEL and Ubuntu supported."
    exit 1
fi

sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat > /dev/null

cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.18/bin/apache-tomcat-11.0.18.tar.gz &> /dev/null

sudo mkdir -p /opt/tomcat
sudo tar xf apache-tomcat-11.0.18.tar.gz -C /opt/tomcat --strip-components=1 > /dev/null
rm -f apache-tomcat-11.0.18.tar.gz

sudo chown -R tomcat:tomcat /opt/tomcat > /dev/null
sudo chmod -R 755 /opt/tomcat > /dev/null

sudo sed -i "s/port=\"8080\"/port=\"$port\"/" /opt/tomcat/conf/server.xml


sudo cp "$path/tomcat.service" /etc/systemd/system/tomcat.service > /dev/null
sudo cp "$path/tomcat-users.txt" /opt/tomcat/conf/tomcat-users.xml > /dev/null
sudo cp "$path/context.txt" /opt/tomcat/webapps/manager/META-INF/context.xml > /dev/null
sudo cp "$path/context.txt" /opt/tomcat/webapps/host-manager/META-INF/context.xml > /dev/null

sudo systemctl daemon-reload > /dev/null
sudo systemctl enable tomcat &> /dev/null
sudo systemctl start tomcat > /dev/null



echo ""
echo "Tomcat installed successfully on $distro"
echo "                 ################################"
echo -e "Access it using: # http://$(curl -s ifconfig.me):$port\t#"
echo "                 ################################"

echo -e "\nTo access Manager and Host-manager, you can use: \nUser:\t\tadmin \nPassword: \tadmin\n"
echo 
echo






echo
echo "Do you want to exit from this script? Or perform another operation?"
echo "1) Exit"
echo "2) Install Jenkins"
echo "3) Install Maven"
echo

read -p "Enter your choice [1-3]: " choice

case $choice in
    1)
        echo "Exiting script..."
        exit 0
        ;;

    2)
        echo "Installing Jenkins again..."
        cd
        sudo yum install git -y > /dev/null 2>&1
        rm -rf install_jenkins_RHEL_Ubuntu
        git clone https://github.com/nagaraj602/install_jenkins_RHEL_Ubuntu.git > /dev/null 2>&1
        cd install_jenkins_RHEL_Ubuntu || exit
        bash jenkins.sh
        ;;

    3)
        echo "Installing Maven..."
        cd
        sudo yum install git -y > /dev/null 2>&1
        rm -rf install_maven_RHEL_Ubuntu
        git clone https://github.com/nagaraj602/install_maven_RHEL_Ubuntu.git > /dev/null 2>&1
        cd install_maven_RHEL_Ubuntu || exit
        bash maven.sh
        ;;

    *)
        echo "Invalid option. Exiting."
        exit 1
        ;;
esac






