wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz
tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz
yum install java-17-amazon-corretto -y
sudo useradd nexus
chown -R  nexus:nexus  nexus-3.79.0-09
sudo sh nexus-3.79.0-09/bin/nexus start

or--------------------------------------------------------------

#!/bin/bash
# ==============================================================================
# Enterprise Setup Script for Nexus Repository Manager 3 on Amazon Linux 2023
# ==============================================================================

set -e

echo "1. Installing Java 17 (Corretto)..."
yum update -y
yum install java-17-amazon-corretto-devel -y

echo "2. Navigating to /opt and downloading Nexus 3..."
cd /opt
wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz

echo "3. Extracting archive..."
tar -zxvf nexus-unix-x86-64-3.79.0-09.tar.gz
rm -f nexus-unix-x86-64-3.79.0-09.tar.gz

echo "4. Creating dedicated 'nexus' system user..."
useradd --system --no-create-home --shell /bin/bash nexus || true

echo "5. Configuring nexus.rc for user enforcement..."
echo 'run_as_user="nexus"' > /opt/nexus-3.79.0-09/bin/nexus.rc

echo "6. Setting directory ownership for application and data folders..."
chown -R nexus:nexus /opt/nexus-3.79.0-09
chown -R nexus:nexus /opt/sonatype-work

echo "7. Creating systemd service file..."
cat <<'EOF' > /etc/systemd/system/nexus.service
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/opt/nexus-3.79.0-09/bin/nexus start
ExecStop=/opt/nexus-3.79.0-09/bin/nexus stop
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "8. Reloading systemd, starting Nexus, and enabling on boot..."
systemctl daemon-reload
systemctl enable nexus
systemctl start nexus

echo "=============================================================================="
echo "Nexus installation complete!"
echo "Wait ~90 seconds for Java startup, then fetch your password via:"
echo "cat /opt/sonatype-work/nexus3/admin.password"
echo "=============================================================================="

Verification Commands

# Check service status
systemctl status nexus

# Verify Nexus is listening on Port 8081 (takes ~60-90s to open)
curl -I http://localhost:8081

# Print initial admin password
cat /opt/sonatype-work/nexus3/admin.password && echo ""
