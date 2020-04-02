###
# ad-group01
# aduser01
# aduser02
#rhel7t01:
{% if salt['grains.get']('os_family') == 'RedHat' %}
{% elif grains['os_family'] == 'Debian' %}
{% else %}
{% endif %}

{% if salt['grains.get']('os_family') == 'RedHat' %}
# only if this is a manageiq appliance.

show_sssd_installed_rpms:
  cmd.run:
    - name: /usr/bin/rpm  -qa |egrep "^sssd-*|sort"
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/rpm

realm_list_existing:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/realm

sssctl_domain-status_test.com:
  cmd.run:
    - name: | 
          /usr/sbin/sssctl domain-status test.com
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

sssctl_config_check:
  cmd.run:
    - name: | 
          /usr/sbin/sssctl --debug=10 config-check
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl


sssctl_user_checks:
  cmd.run:
    - name: | 
          sssctl --debug=1 user-checks aduser01;sssctl --debug=1 user-checks aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

sssctl_user_show:
  cmd.run:
    - name: | 
          sssctl --debug=1 user-show aduser01;sssctl --debug=1 user-show aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

show_sssd_process:
  cmd.run:
    - name: | 
          ps -eaf |egrep "sssd_|sssd\s-i"|grep -v grep
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ps

getend_hosts_rhel7t01:
  cmd.run:
    - name: | 
         getent hosts  rhel7t01.test.com        
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

check_host_on_test.com:
  cmd.run:
    - name: | 
         getent hosts  {{ grains['localhost'] }}.test.com
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent


getent_passwd_aduser02:
  cmd.run:
    - name: | 
         getent passwd aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

getent_passwd_miqadm:
  cmd.run:
    - name: | 
         getent passwd miqadm
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

getent_group_ad-group01:
  cmd.run:
    - name: | 
         getent group ad-group01
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

dbus_aduser01:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:aduser01   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send

dbus_aduser02:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:aduser02   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send




dump_keytab:
  cmd.run:
    - name:  klist -t -k /etc/krb5.keytab
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ls

realm_list_after_join:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/realm 

show_etc_sssd_sssd.conf:
  cmd.run:
    - name: egrep -v '^#|^$' /etc/sssd/sssd.conf 
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/egrep

show_etc_pam.d_system-auth-ac:
  cmd.run:
    - name: cat /etc/pam.d/system-auth-ac | egrep -v '^#|^$' 
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /etc/pam.d/system-auth-ac

if_existed_show_etc-pam.d-httpd-auth:
  cmd.run:
    - name: egrep -v '^#|^$' /etc/pam.d/httpd-auth
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /etc/pam.d/httpd-auth
    - unless: test -f /etc/pam.d/httpd-auth


if_existed_show_var_log_sssd_sssd_test.com.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_test.com.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_test.com.log

if_existed_show_var_log_sssd_sssd_pam.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_pam.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_pam.log

if_existed_show_var_log_sssd_sssd_ifp.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_ifp.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_ifp.log

if_existed_show_var_log_sssd_ldap_child.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/ldap_child.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/ldap_child.log

if_existed_show_var_log_sssd_sssd_nss.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_nss.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_nss.log

{% endif %}


{% if salt['grains.get']('os_family') == 'Debian' %}


realm_list_existing:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/realm

sssctl_domain-status_test.com:
  cmd.run:
    - name: | 
          /usr/sbin/sssctl domain-status test.com
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

sssctl_config_check:
  cmd.run:
    - name: | 
          /usr/sbin/sssctl --debug=10 config-check
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl


sssctl_user_checks:
  cmd.run:
    - name: | 
          sssctl --debug=1 user-checks aduser01;sssctl --debug=1 user-checks aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

sssctl_user_show:
  cmd.run:
    - name: | 
          sssctl --debug=1 user-show aduser01;sssctl --debug=1 user-show aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/sssctl

show_sssd_process:
  cmd.run:
    - name: | 
          ps -eaf |egrep "sssd_|sssd\s-i"|grep -v grep
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ps

getend_hosts_rhel7t01:
  cmd.run:
    - name: | 
         getent hosts  rhel7t01        
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

check_host_on_test.com:
  cmd.run:
    - name: | 
         getent hosts  {{ grains['localhost'] }}.test.com
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent


getent_passwd_sndisco:
  cmd.run:
    - name: | 
         getent passwd sndisco
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

getent_passwd_aduser02:
  cmd.run:
    - name: | 
         getent passwd aduser02
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

getent_passwd_miqadm:
  cmd.run:
    - name: | 
         getent passwd miqadm
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

getent_group_ad-group01:
  cmd.run:
    - name: | 
         getent group ad-group01
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/getent

dbus_aduser01:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:aduser01   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send

dbus_aduser02:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:aduser02   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send


dbus_miqadm:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:miqadm   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send

dbus_admin_miq:
  cmd.run:
    - name: | 
        dbus-send --print-reply --system --dest=org.freedesktop.sssd.infopipe /org/freedesktop/sssd/infopipe org.freedesktop.sssd.infopipe.GetUserAttr string:admin_miq   array:string:mail,givenname,sn,displayname
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/dbus-send

dump_keytab:
  cmd.run:
    - name:  klist -t -k /etc/krb5.keytab
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ls

realm_list_after_join:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/sbin/realm 

show_etc_sssd_sssd.conf:
  cmd.run:
    - name: egrep -v '^#|^$' /etc/sssd/sssd.conf 
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/egrep

show_etc_pam.d_system-auth-ac:
  cmd.run:
    - name: cat /etc/pam.d/system-auth-ac | egrep -v '^#|^$' 
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /etc/pam.d/system-auth-ac

if_existed_show_etc-pam.d-httpd-auth:
  cmd.run:
    - name: egrep -v '^#|^$' /etc/pam.d/httpd-auth
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /etc/pam.d/httpd-auth
    - unless: test -f /etc/pam.d/httpd-auth

if_existed_show_var_log_sssd_sssd_test.com.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_test.com.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_test.com.log

if_existed_show_var_log_sssd_sssd_pam.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_pam.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_pam.log

if_existed_show_var_log_sssd_sssd_ifp.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_ifp.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_ifp.log

if_existed_show_var_log_sssd_ldap_child.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/ldap_child.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/ldap_child.log

if_existed_show_var_log_sssd_sssd_nss.log:
  cmd.run:
    - name: tail -20  /var/log/sssd/sssd_nss.log
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /var/log/sssd/sssd_nss.log

{% endif %}


# do a ldapsearch to see if this host is AD domain
include:
    - .computer-test
