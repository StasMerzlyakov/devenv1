#!/bin/bash

# ! sudo required
LOCAL_DOMAIN=local
LDAP_ADM_NAME=ldapadm
LDAP_ADM_PASSWORD=ldappass

#yum -y install openldap openldap-servers openldap-servers-sql openldap-devel compat-openldap openldap-clients
#
#systemctl start slapd
#systemctl enable slapd
#
#
#firewall-cmd --permanent --add-service=ldap
#firewall-cmd --reload
#
SHA=`slappasswd -h {SSHA} -s ${LDAP_ADM_PASSWORD}`

echo "
dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=ldap,dc=kernelboot,dc=${LOCAL_DOMAIN}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=${LDAP_ADM_NAME},dc=ldap,dc=kernelboot,dc=${LOCAL_DOMAIN}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: ${SHA}
" > /etc/openldap/slapd.d/database.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/database.ldif

echo "
dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth" read by dn.base="cn=${LDAP_ADM_NAME},dc=ldap,dc=kernelboot,dc=${LOCAL_DOMAIN}" read by * none
" > /etc/openldap/slapd.d/monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/slapd.d/monitor.ldif

cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown ldap:ldap /var/lib/ldap/*


ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif 
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

