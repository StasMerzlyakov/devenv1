#!/bin/bash

[ ! -f ./variables ] && echo "file ./variables not exists" && exit 1

source ./variables

[ -z $DOMAIN ] && echo "DOMAIN not set" && exit 1
[ -z $ADM_NAME ] && echo "DOMAIN not set" && exit 1
[ -z $ADM_PASSWORD ] && echo "DOMAIN not set" && exit 1

yum -y install openldap openldap-servers openldap-servers-sql openldap-devel compat-openldap openldap-clients
#
systemctl start slapd
systemctl enable slapd
#
#
firewall-cmd --permanent --add-service=ldap
firewall-cmd --reload
#
SHA=`slappasswd -h {SSHA} -s ${ADM_PASSWORD}`


echo "dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: ${DOMAIN}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=${ADM_NAME},${DOMAIN}

dn: olcDatabase={2}hdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: ${SHA}
" > db.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif


echo "dn: olcDatabase={1}monitor,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth\" read by dn.base=\"cn=${ADM_NAME},${DOMAIN}\" read by * none" > monitor.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap

ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif

rm *.ldif
