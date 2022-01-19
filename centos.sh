#!/bin/bash
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
red='\e[1;31m'
green='\e[0;32m'
NC='\e[0m'
MYIP=$(wget -qO- icanhazip.com);
echo "Checking VPS"
CEKEXPIRED () {
    today=$(date -d +1day +%Y-%m-%d)
    Exp1=$(curl -sS https://raw.githubusercontent.com/liuuufey/aksesip/main/ip | grep $MYIP | awk '{print $3}')
    if [[ $today < $Exp1 ]]; then
    echo -e "\e[32mSTATUS SCRIPT AKTIF...\e[0m"
    else
    echo -e "\e[31mSCRIPT ANDA TELAH EXPIRED!\e[0m";
    echo "Hubungi Admin"
    echo "Telegram Me @liuuufey"
    exit 0
fi
}
IZIN=$(curl -sS https://raw.githubusercontent.com/liuuufey/aksesip/main/ip | awk '{print $4}' | grep $MYIP)
if [ $MYIP = $IZIN ]; then
echo -e "\e[32mPermission Accepted...\e[0m"
CEKEXPIRED
else
echo -e "\e[31mPermission Denied!\e[0m";
echo "Only For Premium Users"
echo "Telegram Me @liuuufey"
exit 0
fi
clear
if [ -f "/etc/xray/domain" ]; then
echo "Script Already Installed"
exit 0
fi
#set repo webmin
cat>/etc/yum.repos.d/webmin.repo<<END
[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1
END
rpm --import http://www.webmin.com/jcameron-key.asc

# go to root
cd
setenforce 0

cat > /etc/sysconfig/selinux <<-END
SELINUX=disabled
END
sestatus

# install wget and curl
yum -y install wget curl

# setting repo centos
yum install -y epel-release

# remove unused
yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl
yum install iptables-services -y
systemctl mask firewalld
systemctl enable iptables
systemctl stop firewalld
systemctl start iptables
iptables --flush

# update
yum -y update

# setting rpmforge
if [[ $ver == '7' ]]; then
wget http://ftp.tu-chemnitz.de/pub/linux/dag/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
rpm -Uvh rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm
yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar
fi

#update kernel
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
if [[ $ver == '7' ]]; then
rpm -Uvh http://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm 
elif [[ $ver == '8' ]]; then
rpm -Uvh http://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm 
fi
yum  --disablerepo="*" --enablerepo="elrepo-kernel" list available
yum -y --enablerepo=elrepo-kernel install kernel-ml
grub2-set-default 0
grub2-mkconfig -o /boot/grub2/grub.cfg

mkdir /var/lib/premium-script;
echo "IP=" >> /var/lib/premium-script/ipvps.conf
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/cf.sh && chmod +x cf.sh && ./cf.sh
#install ssh ovpn
wget https://raw.githubusercontent.com/liuuufey/ws/main/cen-ssh.sh && chmod +x cen-ssh.sh && ./cen-ssh.sh
wget https://raw.githubusercontent.com/liuuufey/ws/main/weleh.sh && chmod +x weleh.sh && ./weleh.sh
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/sstp.sh && chmod +x sstp.sh && ./sstp.sh
#install ssr
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/ssr.sh && chmod +x ssr.sh && ./ssr.sh
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/sodosok.sh && chmod +x sodosok.sh && ./sodosok.sh
#installwg
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/wg.sh && chmod +x wg.sh && ./wg.sh
#install v2ray
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/ins-vt.sh && chmod +x ins-vt.sh && ./ins-vt.sh
#install L2TP
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/ipsec.sh && chmod +x ipsec.sh && ./ipsec.sh
wget https://raw.githubusercontent.com/liuuufey/jhoy/main/set-br.sh && chmod +x set-br.sh && ./set-br.sh
wget https://raw.githubusercontent.com/liuuufey/ws/main/gas-xray.sh && chmod +x gas-xray.sh && ./gas-xray.sh

rm -f /root/ssh-vpn.sh
rm -f /root/weleh.sh
rm -f /root/sstp.sh
rm -f /root/wg.sh
rm -f /root/ss.sh
rm -f /root/ssr.sh
rm -f /root/ins-vt.sh
rm -f /root/ipsec.sh
rm -f /root/set-br.sh
rm -f /root/gas-xray.sh
cat <<EOF> /etc/systemd/system/autosett.service
[Unit]
Description=autosetting
Documentation=https://www.netnot.xyz

[Service]
Type=oneshot
ExecStart=/bin/bash /etc/set.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable autosett
wget -O /etc/set.sh "https://raw.githubusercontent.com/liuuufey/jhoy/main/set.sh"
chmod +x /etc/set.sh
history -c
echo "1.2" > /home/ver
clear
echo " "
echo "Installation has been completed!!"
echo " "
echo "=================================-Autoscript Premium-===========================" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "--------------------------------------------------------------------------------" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - OpenSSH                 : 22"  | tee -a log-install.txt
echo "   - OpenVPN                 : TCP 1194, UDP 2200, SSL 442"  | tee -a log-install.txt
echo "   - Stunnel4                : 222, 777"  | tee -a log-install.txt
echo "   - Dropbear                : 109, 143"  | tee -a log-install.txt
echo "   - Squid Proxy             : 3128, 8080 (limit to IP Server)"  | tee -a log-install.txt
echo "   - Badvpn                  : 7100, 7200, 7300"  | tee -a log-install.txt
echo "   - Nginx                   : 81"  | tee -a log-install.txt
echo "   - Wireguard               : 7070"  | tee -a log-install.txt
echo "   - L2TP/IPSEC VPN          : 1701"  | tee -a log-install.txt
echo "   - PPTP VPN                : 1732"  | tee -a log-install.txt
echo "   - SSTP VPN                : 444"  | tee -a log-install.txt
echo "   - Shadowsocks-R           : 1443-1543"  | tee -a log-install.txt
echo "   - SS-OBFS TLS             : 2443-2543"  | tee -a log-install.txt
echo "   - SS-OBFS HTTP            : 3443-3543"  | tee -a log-install.txt
echo "   - V2RAY Vmess TLS         : 443"  | tee -a log-install.txt
echo "   - V2RAY Vmess None TLS    : 80"  | tee -a log-install.txt
echo "   - V2RAY Vless TLS         : 443"  | tee -a log-install.txt
echo "   - V2RAY Vless None TLS    : 80"  | tee -a log-install.txt
echo "   - Trojan GFW              : 443"  | tee -a log-install.txt
echo "   - Trojan Go               : 443"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo "   - Timezone                : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo "   - IPtables                : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo "   - IPv6                    : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On 05.00 GMT +7" | tee -a log-install.txt
echo "   - Autobackup Data" | tee -a log-install.txt
echo "   - Restore Data" | tee -a log-install.txt
echo "   - Auto Delete Expired Account" | tee -a log-install.txt
echo "   - Full Orders For Various Services" | tee -a log-install.txt
echo "   - White Label" | tee -a log-install.txt
echo "   - Installation Log --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   - Dev/Main                : Jhoy"  | tee -a log-install.txt
echo "   - Telegram                : @liuuufey"  | tee -a log-install.txt
echo "------------------Script Created By Jhoy-----------------" | tee -a log-install.txt
echo ""
echo " Reboot 15 Sec"
sleep 15
rm -f setup.sh
reboot
