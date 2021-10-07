#!/bin/bash -x
apt install php-zip php-sqlite3 php-xml php-mbstring php-cli -y
cd /opt
RELEASE=$(curl -sX GET "https://api.github.com/repos/linuxserver/Heimdall/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]')
echo ${RELEASE}
curl --silent -o Heimdall-${RELEASE}.tar.gz -L "https://github.com/linuxserver/Heimdall/archive/${RELEASE}.tar.gz"
tar xvzf Heimdall-*.tar.gz
mv Heimdall-${RELEASE} Heimdall
cd Heimdall
cp .env.example .env
sed -i '135d;136d' ./vendor/symfony/console/Input/ArrayInput.php
php artisan key:generate

SERVICEFILE=/etc/systemd/system/heimdall.service
SERVICEFILE=/lib/systemd/system/heimdall.service

echo "[Unit]" > ${SERVICEFILE}
echo "Description=Heimdall" >> ${SERVICEFILE}
echo "After=network.target" >> ${SERVICEFILE}
echo " " >> ${SERVICEFILE}
echo "[Service]" >> ${SERVICEFILE}
echo "Restart=always" >> ${SERVICEFILE}
echo "RestartSec=10" >> ${SERVICEFILE}
echo "Type=simple" >> ${SERVICEFILE}
echo "User=root" >> ${SERVICEFILE}
echo "Group=root" >> ${SERVICEFILE}
echo "WorkingDirectory=/opt/Heimdall" >> ${SERVICEFILE}
echo "ExecStart=\"/usr/bin/php\" artisan serve --port=8000 --host=0.0.0.0" >> ${SERVICEFILE}
echo "TimeoutStopSec=30" >> ${SERVICEFILE}
echo " " >> ${SERVICEFILE}
echo "[Install]" >> ${SERVICEFILE}
echo "WantedBy=multi-user.target" >> ${SERVICEFILE}

systemctl daemon-reload
systemctl enable heimdall.service
systemctl restart heimdall.service
