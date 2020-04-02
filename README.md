# bash 
bash script about joining and leaving active directory

# saltstack

- following is sls file layout using salt gitfs
```
[me@salt01 auth]$ tree saltstack
saltstack
├── files
│   ├── etc-pam.d-common-session
│   ├── etc-pam.d-password-auth-sssd
│   ├── etc-sssd-sssd.conf.test.com
│   └── etc-sssd-sssd.conf.test.com.ubuntu
├── get-computer.sls      # to verify if this Unix added into AD server by using ldap search command
├── join-ad.sls           # main ad join sls file
├── precheck-ad.sls       # do a pre-check, called by join-ad.sls
└── test-ad.sls           # run a bunch commands to display AD binding status

1 directory, 8 files
[me@salt01 auth]$
```

- Example usage if gitfs is configure properply on salt master.

```
# Running from salt-minion to join to join domain
sudo salt-call  state.sls mygit.auth.join-ad      # to join domain
sudo salt-call  state.sls mygit.auth.get-computer # to see if host is added into domain
sudo salt-call  state.sls mygit.auth.test-ad      # to run some commands to display binding details

# Running from slat01 master 
sudo salt minion01 state.sls mygit.auth.join-ad      # to join domain
sudo salt minion01 state.sls mygit.auth.get-computer # to see if host is added into domain
sudo salt minion01 state.sls mygit.auth.test-ad      # to run some commands to display binding details
```