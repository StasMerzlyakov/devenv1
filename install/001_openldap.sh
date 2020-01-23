#!/bin/bash

# ! sudo required
# domain: unit.organization.ru
UNIT=unit
DOMAIN="dc=${UNIT},dc=organization,dc=ru"
DATE=`date +%Y_%d_%m`
ADM_NAME=ldapadm
ADM_PASSWORD=ldappass

CERT_NAME="${DATE}.cert"
KEY_NAME="${DATE}.key"

#yum -y install openldap openldap-servers openldap-servers-sql openldap-devel compat-openldap openldap-clients
##
#systemctl start slapd
#systemctl enable slapd
##
##
#firewall-cmd --permanent --add-service=ldap
#firewall-cmd --reload
##
#SHA=`slappasswd -h {SSHA} -s ${ADM_PASSWORD}`
#

#echo "dn: olcDatabase={2}hdb,cn=config
#changetype: modify
#replace: olcSuffix
#olcSuffix: ${DOMAIN}
#
#dn: olcDatabase={2}hdb,cn=config
#changetype: modify
#replace: olcRootDN
#olcRootDN: cn=${ADM_NAME},${DOMAIN}
#
#dn: olcDatabase={2}hdb,cn=config
#changetype: modify
#replace: olcRootPW
#olcRootPW: ${SHA}
#" > db.ldif
#
#ldapmodify -Y EXTERNAL  -H ldapi:/// -f db.ldif


#echo "dn: olcDatabase={1}monitor,cn=config
#changetype: modify
#replace: olcAccess
#olcAccess: {0}to * by dn.base=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external, cn=auth\" read by dn.base=\"cn=${ADM_NAME},${DOMAIN}\" read by * none" > monitor.ldif
#
#ldapmodify -Y EXTERNAL  -H ldapi:/// -f monitor.ldif
#


## TODO - parameters !!
# openssl req -new -x509 -nodes -out 
# /etc/openldap/certs/${CERT_NAME} \
#-keyout /etc/openldap/certs/${KEY_NAME} \
#-days 365

#chown -R ldap:ldap /etc/openldap/certs
#
#echo "dn: cn=config
#changetype: modify
#replace: olcTLSCertificateKeyFile
#olcTLSCertificateKeyFile: /etc/openldap/certs/${KEY_NAME}
#
#
#dn: cn=config
#changetype: modify
#replace: olcTLSCertificateFile
#olcTLSCertificateFile: /etc/openldap/certs/${CERT_NAME}" > certs.ldif
#
#ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif


#cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
#chown -R ldap:ldap /var/lib/ldap

#ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
#ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/nis.ldif
#ldapadd -Y EXTERNAL  -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif


echo "dn: ${DOMAIN}
dc: ${UNIT}
objectClass: top
objectClass: domain

dn: cn=${ADM_NAME},${DOMAIN}
objectClass: organizationalRole
cn: ${ADM_NAME}
description: LDAP Manager

dn: ou=People,${DOMAIN}
objectClass: organizationalUnit
ou: People

dn: ou=Group,${DOMAIN}
objectClass: organizationalUnit
ou: Group" > ./base.ldif

ldapadd -x -W -D "cn=${ADM_NAME},${DOMAIN}" -f base.ldif


rm *.ldif
