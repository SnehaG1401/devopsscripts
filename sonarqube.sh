#! /bin/bash
cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
sudo dnf install java-17-amazon-corretto -y
useradd sonar
chown sonar:sonar sonarqube-8.9.6.50800 -R
chmod 777 sonarqube-8.9.6.50800 -R
su - sonar
# use the below command manually after installation
#sh /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
#echo "user=admin & password=admin"

OR----------------------------------------------------------------------------------------

#!/bin/bash
# Description: Automated Installation Script for SonarQube 8.9.6 LTS on Amazon Linux

set -e

echo "=== 1. Moving to /opt and downloading SonarQube 8.9.6 ==="
cd /opt/
wget -N https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip -q -o sonarqube-8.9.6.50800.zip

echo "=== 2. Installing Java 11 (Required for SonarQube 8.9) and Unzip ==="
dnf install -y java-11-amazon-corretto-devel unzip

# Set Java 11 as the default system Java
alternatives --set java /usr/lib/jvm/java-11-amazon-corretto.x86_64/bin/java 2>/dev/null || true

echo "=== 3. Setting required Elasticsearch kernel memory parameters ==="
sysctl -w vm.max_map_count=262144
grep -qF "vm.max_map_count=262144" /etc/sysctl.conf || echo "vm.max_map_count=262144" >> /etc/sysctl.conf

echo "=== 4. Creating 'sonar' user and setting permissions ==="
id -u sonar &>/dev/null || useradd sonar
chown -R sonar:sonar /opt/sonarqube-8.9.6.50800
chmod -R 755 /opt/sonarqube-8.9.6.50800

echo "=== 5. Starting SonarQube as 'sonar' user ==="
su - sonar -c "/opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh restart"

echo "=== Installation Completed Successfully! ==="
echo "Wait 20 seconds for initialization, then access: http://<YOUR_EC2_PUBLIC_IP>:9000"
echo "Default Credentials -> User: admin | Password: admin"
