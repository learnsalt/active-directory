#!/usr/bin/env bash

# Ref:
#  1. https://www.reddit.com/r/CentOS/comments/d98lip/joining_centos_8_to_active_directory_with_realm/
#wait for network, fail after 20 seconds
NETWAIT=0
until /usr/sbin/ip route | /usr/bin/grep default; do
    if [ $NETWAIT -gt 20 ]; then
        exit 1;
    fi
    /bin/sleep 1
    NETWAIT=$((NETWAIT+1))
done

#declare variables
OUPATH="OU=Member Servers"
AUTHGROUP="dl linux admins"
SUDOGROUP="`echo $AUTHGROUP | sed "s/ /\\\\\ /g"`"
DOMAIN=`hostname -d`
DOMAINUPPER=${DOMAIN^^}
DJOINACCOUNT="DJOINSERVICEACCOUNT"
DJOINPASSWORD="DJOINSERVICEACCOUNTPASSWORD"

#install dependancies
/usr/bin/yum install bind-utils realmd oddjob oddjob-mkhomedir sssd samba-common-tools PackageKit krb5-workstation adcli -y
/usr/bin/yum update -y

#test domain connectivity
if ! /usr/bin/nslookup -type=SRV _ldap._tcp.dc._msdcs.$DOMAIN; then
    exit 1;
fi

#install vmware guest additions if applicable
if [ `/usr/bin/systemd-detect-virt | /usr/bin/grep vmware` ]; then
    /usr/bin/yum install open-vm-tools -y && /usr/bin/systemctl enable --now vmtoolsd;
fi

#enable sssd
/usr/bin/systemctl enable --now sssd.service

#configure hostname
/usr/bin/hostnamectl set-hostname `/usr/bin/hostname -f`

#configure kerberos
/usr/bin/tee /etc/krb5.conf 1>/dev/null << EOF
[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true
 default_realm = $DOMAINUPPER
 default_ccache_name = KEYRING:persistent:%{uid}

 default_realm = $DOMAINUPPER
[realms]
 $DOMAINUPPER = {
 }

[$DOMAIN]
 $DOMAIN = $DOMAINUPPER
 .$DOMAIN = $DOMAINUPPER
EOF

#configure realmd
/usr/bin/tee /etc/realmd.conf 1>/dev/null << EOF
[active-directory]
os-name = Centos
os-version = 8

[service]
automatic-install = yes

[users]
default-home = /home/%u
default-shell = /bin/bash

[$DOMAIN]
user-principal = yes
fully-qualified-names = no
EOF

#join domain
/usr/bin/echo $DJOINPASSWORD | /usr/sbin/realm join -U $DJOINACCOUNT $DOMAIN --membership-software=adcli --computer-ou="$OUPATH"

#configure sssd
/usr/bin/tee /etc/sssd/sssd.conf 1>/dev/null << EOF
[sssd]
domains = $DOMAIN
config_file_version = 2
services = nss, pam

[domain/$DOMAIN]
ad_domain = $DOMAIN
krb5_realm = $DOMAINUPPER
#default_domain_suffix = $DOMAIN
use_fully_qualified_names = false

re_expression = (((?P<domain>[^\\\]+)\\\(?P<name>.+$))|((?P<name>[^@]+)@(?P<domain>.+$))|(^(?P<name>[^@\\\]+)$))
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
fallback_homedir = /home/%u
auth_provider = ad
chpass_provider = ad
access_provider = ad

ldap_schema = ad

dyndns_update = true
dyndns_refresh_interval = 43200
dyndns_update_ptr = true
dyndns_ttl = 3600
ldap_id_mapping = true
EOF
/usr/bin/chmod 600 /etc/sssd/sssd.conf
/usr/bin/systemctl restart sssd.service

#configure authorization
/usr/sbin/realm permit --groups "$AUTHGROUP"
/usr/bin/echo "%$SUDOGROUP    ALL=(ALL)    NOPASSWD:    ALL" | sudo tee -a /etc/sudoers

#configure ssh to use gssapi and disable root login
/usr/bin/sed -i "s/GSSAPICleanupCredentials no/GSSAPICleanupCredentials yes/g" /etc/ssh/sshd_config
/usr/bin/sed -i "s/PermitRootLogin yes/#PermitRootLogin yes/g" /etc/ssh/sshd_config

#purge user kerberos tickets on logout
/usr/bin/echo kdestroy | sudo tee /etc/bash.bash_logout

#remove domain join cronjob and delete script
/usr/bin/crontab -l | grep -v '@reboot /etc/djoin.sh'  | /usr/bin/crontab -
/usr/bin/rm -- "$0"

#reboot system
/usr/sbin/reboot
