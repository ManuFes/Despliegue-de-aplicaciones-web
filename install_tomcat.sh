#!/bin/bash

# Disable the kernel update screen
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf

# Update the package list and install updates
apt update
apt upgrade -y

# Install JDK 21
apt install -y openjdk-21-jdk

# Create a tomcat user without privileges
useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# Download and install Tomcat 11
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.2/bin/apache-tomcat-11.0.2.tar.gz
tar -xzf apache-tomcat-11.0.2.tar.gz -C /opt/tomcat --strip-components=1

# Assign permissions to the tomcat user for the Tomcat installation
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

# Configure admin users in Tomcat
sed -i '/<\/tomcat-users>/i \
<role rolename="manager-gui" />\n\
<user username="manager" password="1234" roles="manager-gui" />\n\
<role rolename="admin-gui" />\n\
<user username="admin" password="1234" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

# Allow external access to Tomcat management applications
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# Create and configure the systemd service for Tomcat
echo '[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.21.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/tomcat.service

# Reload systemd services
systemctl daemon-reload

# Enable the Tomcat service to start automatically at system boot
systemctl enable tomcat

# Start the Tomcat service
systemctl start tomcat