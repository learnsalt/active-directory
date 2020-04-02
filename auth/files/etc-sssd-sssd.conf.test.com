[sssd]
domains = test.com
config_file_version = 2
services = nss, pam, ifp
#default_domain_suffix = test.com
#debug_level = 9

[nss]
homedir_substring = /home
filter_groups = root
filter_users = root,lightdm,ldap,named,avahi,haldaemon,dbus,radvd,tomcat,radiusd,news,mailman,nscd
#debug_level = 9

[pam]
pam_verbosity = 3
#debug_level = 9

[ifp]
allowed_uids = apache, root
user_attributes = +mail, +givenname, +sn, +displayname
#debug_level = 9

[domain/test.com]
ad_server = adserver01.test.com 
ad_domain = test.com
ad_site   = test.com
krb5_realm = test.com
realmd_tags = manages-system joined-with-samba
cache_credentials = True
id_provider = ad
auth_provider = ad
chpass_provider = ad
access_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
fallback_homedir = /home/%u
ldap_user_extra_attrs = mail, givenname, sn, displayname
timeout = 3600
dyndns_update = false
use_fully_qualified_names = False
ignore_group_members = True
ad_gpo_access_control = permissive
