#!/bin/bash

TMPFILE="${1}" # Temp file from OpenVPN
OPENVPN_USERNAME="`head -n1 ${TMPFILE} | tail -n1`"
OPENVPN_PASSWORD="`head -n2 ${TMPFILE} | tail -n1`"
LDAP_HOST="ldap://ldap-01"
LDAP_DOMAIN="ou=users,dc=dominio,dc=com"
LDAP_BINDDN="dc=dominio,dc=com"
LDAP_BINDUSER="uid=usuario,ou=users,dc=dominio,dc=com"
LDAP_BINDPASSWORD="Pa$$w0rd"
LDAP_GROUP="GROUP-vpn,ou=group,dc=dominio,dc=com"
#LDAP_SEARCHFILTER="(&(objectClass=organizationalPerson)(!(userAccountControl:1.2.840.113556.1.4.803:=2))(objectClass=user)(memberOf=CN=vpn-new,OU=ServiceObjects,DC=mydomain,DC=domain,DC=com)(sAMAccountName=${OPENVPN_USERNAME}))"
LDAP_SEARCHFILTER="(&(objectClass=Person)(uid=${OPENVPN_USERNAME})(memberOf=CN=${LDAP_GROUP}))"
LDAP_SAMACCOUNTNAME=`ldapsearch -LLL -H "${LDAP_HOST}" -x -D "${LDAP_BINDUSER}" -w "${LDAP_BINDPASSWORD}" -E pr=1000/noprompt -b "${LDAP_BINDDN}" "${LDAP_SEARCHFILTER}" | grep uid: | awk -F ":" '{print $2}' | sed -r 's/[[:space:]]//'`
if [ "${LDAP_SAMACCOUNTNAME}" == "" ]; then
        echo "LDAPAUTH: Wrong username or the user got filtered out by searchfilter (disabled account or group membership)"&> /var/log/ldap-auth.log
        exit 1
fi


ldapsearch -LLL -H "${LDAP_HOST}" -x -D "uid=${LDAP_SAMACCOUNTNAME},${LDAP_DOMAIN}" -w "${OPENVPN_PASSWORD}" -E pr=1000/noprompt -b "${LDAP_BINDDN}" "${LDAP_SEARCHFILTER}" &> /var/log/ldap-auth.log
if [ $? != 0 ]; then
        echo "LDAPAUTH: Wrong password for user: ${LDAP_DOMAIN}\\${LDAP_SAMACCOUNTNAME}"
        exit 1
fi

exit 0
