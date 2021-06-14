Usage

you have to enable memberof overly on LDAP server and create a group "GROUP-vpn" then
Copy ldapsearch-auth.sh to /etc/openvpn/server/

edit /etc/openvpn/server/server.conf and add this lines:

### Authentication Setting de internet###
script-security 2
username-as-common-name
auth-user-pass-verify /etc/openvpn/server/ldapsearch-auth.sh via-file
