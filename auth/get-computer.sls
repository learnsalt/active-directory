# Note
# 1. this sls file is to verify computer(this unix host) is added into AD server.

{% if salt['grains.get']('os_family') == 'RedHat' %}
{% elif grains['os_family'] == 'Debian' %}
{% else %}

{% endif %}

{% if salt['grains.get']('os_family') == 'RedHat' %}

# once joined the AD server, this script will use current host name to do a ldap server to see if this hostname is added.
check_computer_on_test.com:
  cmd.run:
    - name: |
       ldapsearch -x -b "CN={{ grains['localhost'] }},OU=MyOU01,OU=Servers,dc=test,dc=com" -D "ad_admin01@test.com" -h test.com -w "admin01_password"
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ldapsearch

{% endif %}

{% if salt['grains.get']('os_family') == 'Debian' %}

check_computer_on_test.com:
  cmd.run:
    - name: |
       ldapsearch -x -b "CN={{ grains['localhost'] }},OU=MyOU01,OU=Servers,dc=test,dc=com" -D "ad_admin01@test.com" -h test.com -w "admin01_password"
    - shell: /bin/bash
    - timeout: 300
    - onlyif: test -f /usr/bin/ldapsearch

{% endif %}

