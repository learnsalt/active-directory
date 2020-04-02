# Note:
#  1. this scrip is on git server using salt gitfs
# TODOs:
#  1. Need to handle when a host is already joined the AD domain
#  2. Hide password  in the sls file ?

{% if salt['grains.get']('os_family') == 'RedHat' %}
  {% set sssd_pkg = 'sssd' %}
  {% set sssd_service = 'sssd' %}
{% elif grains['os_family'] == 'Debian' %}
{% else %}

{% endif %}

include:
    - .precheck-ad

{% if salt['grains.get']('os_family') == 'RedHat' %}

AD binding needed packages:
 pkg.installed:
    - pkgs:
      - oddjob  
      - oddjob-mkhomedir 
      - samba-common-tools
      - sssd-ad
      - realmd 
      - sssd 
      - krb5-workstation 
      - sssd-ad
      - sssd-tools
      - adcli
      - openldap-clients

{% if salt['grains.get']('osfinger') == 'Red Hat Enterprise Linux-8' or salt['grains.get']('osfinger') == 'CentOS Linux-8'  %}
utility_packages8:
 pkg.installed:
    - pkgs:
      - selinux-policy-targeted
# lazy trick to avoic firewalld config
selinux_mode:
  selinux.mode:
    - name: disabled
    - require:
      - pkg: utility_packages8
{% else %}
utility_packages:
 pkg.installed:
    - pkgs:
      - policycoreutils-python
      - selinux-policy-targeted
selinux_mode:
  selinux.mode:
    - name: disabled
    - require:
      - pkg: utility_packages

{% endif %}

# For binding to AD server(say, test.com)
# test.com should not have this computer account already.
# if yes, test team need to remove it from test.com
realm_list_existing:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

Delete_existing_var_lib_sss_ldb files:
  cmd.run:
    - name: find /var/lib/sss/ -name '*.ldb' -delete
    - shell: /bin/bash
    - timeout: 300

join_test_com:
  cmd.run:
    - name: echo admin01_password | /usr/sbin/realm join -v --membership-software=adcli --computer-ou=ou=motorola,ou=servers,dc=test,dc=com test.com  -U ad_admin01
    - shell: /bin/bash
    - timeout: 120
    - unless: test -f /etc/sssd.d/sssd.conf

check_keytab:
  cmd.run:
    - name: ls -l /etc/krb5.keytab
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

realm_list_after_join:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

# for OS auth
/etc/pam.d/password-auth:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - source:
      - salt://mygit/auth/files/etc-pam.d-password-auth-sssd

# SSSD config file
/etc/sssd/sssd.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - source:
      - salt://mygit/auth/files/etc-sssd-sssd.conf.test.com


sssd:
  service.running:
      - watch:
         - file: /etc/sssd/sssd.conf

oddjobd:
  service.running:
      - enable: True
      - watch:
         - file: /etc/sssd/sssd.conf

klist_after_restart:
  cmd.run:
    - name: /usr/bin/klist
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/krb5.keytab


{% endif %}


{% if salt['grains.get']('os_family') == 'Debian' %}

Ubuntu packages for AD binding:
 pkg.installed:
    - pkgs:
      - realmd
      - sssd
      - sssd-dbus
      - sssd-tools
      - libnss-sss
      - libpam-sss
      - krb5-user
      - adcli
      - samba-common-bin
      - policykit-1
      - packagekit
      
Ubuntu utility_packages:
 pkg.installed:
    - pkgs:
      - ntp
      - ntpdate

realm_list_existing:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

# to enable home dir autocreation for remote user, ie account from test.com
/etc/pam.d/common-session:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - source:
      - salt://mygit/auth/files/etc-pam.d-common-session

join_test_com:
  cmd.run:
    - name: /root/testad --join -a ad_admin01 -p admin01_password
    - shell: /bin/bash
    - timeout: 120
    - unless: test -f /etc/sssd.d/sssd.conf

check_keytab:
  cmd.run:
    - name: ls -l /etc/krb5.keytab
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

realm_list_after_join:
  cmd.run:
    - name: /usr/sbin/realm list
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/sssd.d/sssd.conf

# SSSD config file
#
/etc/sssd/sssd.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 0600
    - source:
      - salt://mygit/auth/files/etc-sssd-sssd.conf.test.com.ubuntu
sssd:
  service.running:
      - watch:
         - file: /etc/sssd/sssd.conf

klist_after_restart:
  cmd.run:
    - name: /usr/bin/klist
    - shell: /bin/bash
    - timeout: 300
    - unless: test -f /etc/krb5.keytab

{% endif %}

