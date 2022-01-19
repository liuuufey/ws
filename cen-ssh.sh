#!/bin/bash
#
# ==================================================

# initializing var
export CENTOS_FRONTEND=noninteractive
MYIP=$(wget -qO- ifconfig.me/ip);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=Indonesia
locality=Indonesia
organization=www.netnot.xyz
organizationalunit=www.netnot.xyz
commonname=www.netnot.xyz
email=admin@netnot.xyz

# simple password minimal
wget -O /etc/pam.d/common-password "https://raw.githubusercontent.com/liuuufey/jhoy/main/password"
chmod +x /etc/pam.d/common-password

# go to root
cd

# Edu OVPN
wget -q -O /usr/local/bin/edu-ovpn https://raw.githubusercontent.com/liuuufey/jhoy/main/cdn-ovpn.py
chmod +x /usr/local/bin/edu-ovpn

# Installing Service
cat > /etc/systemd/system/edu-ovpn.service << END
[Unit]
Description=Python Edu Ovpn By Liuuufey
Documentation=https://www.netnot.xyz
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python -O /usr/local/bin/edu-ovpn 2082
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable edu-ovpn
systemctl restart edu-ovpn

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local


# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install essential package
yum -y install net-snmp net-snmp-utils
yum -y install iftop 
yum -y install htop
yum -y groupinstall 'Development Tools'
yum -y install cmake
yum -y install wget
yum -y install unzip
yum -y install git
yum -y install make
yum -y install gcc
yum -y install gcc-c++
yum -y install screen
yum -y install nano

# install neofetch centos
if [[ $ver == '7' ]]; then
git clone https://github.com/dylanaraps/neofetch
cd neofetch
make install
make PREFIX=/usr/local install
make PREFIX=/boot/home/config/non-packaged install
make -i install
cd
rm -rf neofetch
elif [[ $ver == '8' ]]; then
yum -y install neofetch
fi
cd
echo "clear" >> .bash_profile
echo "neofetch" >> .bash_profile
echo "service-info" >> .bash_profile

# install webserver
if [[ -e /etc/debian_version ]]; then
	source /etc/os-release
	OS=$ID # debian or ubuntu
elif [[ -e /etc/centos-release ]]; then
	source /etc/os-release
	OS=centos
fi
if [[ $OS == 'ubuntu' ]]; then
		sudo add-apt-repository ppa:ondrej/nginx -y
		apt update ; apt upgrade -y
		sudo apt install nginx -y
		sudo apt install python3-certbot-nginx -y
		systemctl daemon-reload
        systemctl enable nginx
elif [[ $OS == 'debian' ]]; then
	   sudo apt install gnupg2 ca-certificates lsb-release -y 
       echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list 
       echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
       curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key 
       # gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
       sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
       apt update
       apt -y install nginx 
       systemctl daemon-reload
        
fi
rm /etc/nginx/conf.d/default.conf
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/liuuufey/jhoy/main/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/liuuufey/jhoy/main/vps.conf"
systemctl enable nginx
mkdir -p /home/vps/public_html
/etc/init.d/nginx restart

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/liuuufey/jhoy/main/badvpn-udpgw64"
chmod +x /usr/bin/badvpn-udpgw
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500' /etc/rc.local
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500' /etc/rc.local
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500

# setting port ssh
sed -i '/Port 22/a Port 88' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config

# install dropbear
yum -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 69"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells

# install squid
cd
yum -y install squid3
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/liuuufey/jhoy/main/squid3.conf"
sed -i $MYIP2 /etc/squid/squid.conf

# setting vnstat
yum -y install vnstat
/etc/init.d/vnstat restart
yum -y install libsqlite3-dev
wget https://humdi.net/vnstat/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install
cd
vnstat -u -i $NET
sed -i 's/Interface "'""eth0""'"/Interface "'""$NET""'"/g' /etc/vnstat.conf
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz
rm -rf /root/vnstat-2.6

# install stunnel
yum install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 222
connect = 127.0.0.1:109

[dropbear]
accept = 777
connect = 127.0.0.1:22

[openvpn]
accept = 442
connect = 127.0.0.1:1194

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

#OpenVPN
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/vpn.sh &&  chmod +x vpn.sh && ./vpn.sh

# install fail2ban
yum -y install fail2ban

# install webmin
cd
yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty
yum install webmin -y
sed -i -e 's/ssl=1/ssl=0/g' /etc/webmin/miniserv.conf
service webmin restart
chkconfig webmin on

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'

# banner /etc/issue.net
echo "Banner /etc/issue.net" >>/etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# blockir torrent
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables-save > /etc/iptables.up.rules
iptables-restore -t < /etc/iptables.up.rules
netfilter-persistent save
netfilter-persistent reload

# download script
cd /usr/bin
wget -O add-ws "https://raw.githubusercontent.com/liuuufey/jhoy/main/add-ws.sh"
wget -O add-vless "https://raw.githubusercontent.com/liuuufey/jhoy/main/add-vless.sh"
wget -O add-tr "https://raw.githubusercontent.com/liuuufey/jhoy/main/add-tr.sh"
wget -O add-trgo "https://raw.githubusercontent.com/liuuufey/jhoy/main/add-trgo.sh"
wget -O cek-ws "https://raw.githubusercontent.com/liuuufey/jhoy/main/cek-ws.sh"
wget -O cek-vless "https://raw.githubusercontent.com/liuuufey/jhoy/main/cek-vless.sh"
wget -O cek-tr "https://raw.githubusercontent.com/liuuufey/jhoy/main/cek-tr.sh"
wget -O cek-trgo "https://raw.githubusercontent.com/liuuufey/jhoy/main/cek-trgo.sh"
wget -O del-ws "https://raw.githubusercontent.com/liuuufey/jhoy/main/del-ws.sh"
wget -O del-vless "https://raw.githubusercontent.com/liuuufey/jhoy/main/del-vless.sh"
wget -O del-tr "https://raw.githubusercontent.com/liuuufey/jhoy/main/del-tr.sh"
wget -O del-trgo "https://raw.githubusercontent.com/liuuufey/jhoy/main/del-trgo.sh"
wget -O renew-ws "https://raw.githubusercontent.com/liuuufey/jhoy/main/renew-ws.sh"
wget -O renew-vless "https://raw.githubusercontent.com/liuuufey/jhoy/main/renew-vless.sh"
wget -O renew-tr "https://raw.githubusercontent.com/liuuufey/jhoy/main/renew-tr.sh"
wget -O renew-trgo "https://raw.githubusercontent.com/liuuufey/jhoy/main/renew-trgo.sh"
wget -O add-host "https://raw.githubusercontent.com/liuuufey/jhoy/main/add-host.sh"
wget -O certv2ray "https://raw.githubusercontent.com/liuuufey/jhoy/main/certxray.sh"
wget -O about "https://raw.githubusercontent.com/liuuufey/jhoy/main/about.sh"
wget -O usernew "https://raw.githubusercontent.com/liuuufey/jhoy/main/usernew.sh"
wget -O trial "https://raw.githubusercontent.com/liuuufey/jhoy/main/trial.sh"
wget -O hapus "https://raw.githubusercontent.com/liuuufey/jhoy/main/hapus.sh"
wget -O member "https://raw.githubusercontent.com/liuuufey/jhoy/main/member.sh"
wget -O delete "https://raw.githubusercontent.com/liuuufey/jhoy/main/delete.sh"
wget -O cek "https://raw.githubusercontent.com/liuuufey/jhoy/main/cek.sh"
wget -O restart "https://raw.githubusercontent.com/liuuufey/jhoy/main/restart.sh"
wget -O speedtest "https://raw.githubusercontent.com/liuuufey/jhoy/main/speedtest_cli.py"
wget -O info "https://raw.githubusercontent.com/liuuufey/jhoy/main/info.sh"
wget -O ram "https://raw.githubusercontent.com/liuuufey/jhoy/main/ram.sh"
wget -O renew "https://raw.githubusercontent.com/liuuufey/jhoy/main/renew.sh"
wget -O autokill "https://raw.githubusercontent.com/liuuufey/jhoy/main/autokill.sh"
wget -O ceklim "https://raw.githubusercontent.com/liuuufey/jhoy/main/ceklim.sh"
wget -O tendang "https://raw.githubusercontent.com/liuuufey/jhoy/main/tendang.sh"
wget -O clear-log "https://raw.githubusercontent.com/liuuufey/jhoy/main/clear-log.sh"
wget -O wbmn "https://raw.githubusercontent.com/liuuufey/jhoy/main/webmin.sh"
wget -O xp "https://raw.githubusercontent.com/liuuufey/jhoy/main/xp.sh"
wget -O swap "https://raw.githubusercontent.com/liuuufey/jhoy/main/swapkvm.sh"
wget -O menu "https://raw.githubusercontent.com/liuuufey/jhoy/main/menu.sh"
wget -O bbr "https://raw.githubusercontent.com/liuuufey/jhoy/main/update/bbr.sh"
wget -O bannerku "https://raw.githubusercontent.com/liuuufey/jhoy/main/bannerku"
wget -O /usr/bin/user-limit https://raw.githubusercontent.com/liuuufey/jhoy/main/user-limit.sh && chmod +x /usr/bin/user-limit
wget -O autoreboot "https://raw.githubusercontent.com/liuuufey/jhoy/main/autoreboot.sh"
wget -O service-status "https://raw.githubusercontent.com/liuuufey/jhoy/main/service.sh"
wget -O service-info "https://raw.githubusercontent.com/liuuufey/jhoy/main/service-info.sh"
wget -O update "https://raw.githubusercontent.com/liuuufey/jhoy/main/update.sh"
chmod +x add-ws
chmod +x add-vless
chmod +x add-tr
chmod +x add-trgo
chmod +x cek-ws
chmod +x cek-vless
chmod +x cek-tr
chmod +x cek-trgo
chmod +x del-ws
chmod +x del-vless
chmod +x del-tr
chmod +x del-trgo
chmod +x renew-ws
chmod +x renew-vless
chmod +x renew-tr
chmod +x renew-trgo
chmod +x add-host
chmod +x certv2ray
chmod +x usernew
chmod +x trial
chmod +x hapus
chmod +x member
chmod +x delete
chmod +x cek
chmod +x restart
chmod +x speedtest
chmod +x info
chmod +x ram
chmod +x renew
chmod +x about
chmod +x autokill
chmod +x ceklim
chmod +x tendang
chmod +x clear-log
chmod +x wbmn
chmod +x xp
chmod +x swap
chmod +x menu
chmod +x bbr
chmod +x bannerku
chmod +x autoreboot
chmod +x service-status
chmod +x service-info
chmod +x update
echo "0 5 * * * root clear-log && reboot" >> /etc/crontab
echo "0 0 * * * root xp" >> /etc/crontab
# remove unnecessary files
cd
yum autoclean -y
yum -y remove --purge unscd
yum -y remove samba*;
yum -y remove apache2*;
yum -y remove bind9*;
yum -y remove sendmail*
yum autoremove -y
# finishing
cd
chown -R www-data:www-data /home/vps/public_html
/etc/init.d/nginx restart
/etc/init.d/openvpn restart
/etc/init.d/cron restart
/etc/init.d/ssh restart
/etc/init.d/dropbear restart
/etc/init.d/fail2ban restart
/etc/init.d/stunnel4 restart
/etc/init.d/vnstat restart
/etc/init.d/squid restart
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7600 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7700 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7800 --max-clients 500
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7900 --max-clients 500
history -c
echo "unset HISTFILE" >> /etc/profile

cd
rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh

# finihsing
clear
