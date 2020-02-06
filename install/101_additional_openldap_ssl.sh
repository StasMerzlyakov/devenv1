#!/bin/bash

# ! sudo required
# domain: unit.organization.ru
DOMAIN="dc=unit,dc=organization,dc=ru"

ADM_NAME=ldapadm
ADM_PASSWORD=ldappass

## ldap certificate subject
# /C=NL: 2 letter ISO country code (Netherlands)
# /ST=: State, Zuid Holland (South holland)
# /L=: Location, city (Rotterdam)
# /O=: Organization (Sparkling Network)
# /OU=: Organizational Unit, Department (IT Department, Sales)
# /CN=: Common Name, for a website certificate this is the FQDN. (ssl.raymii.org)
SUBJECT="/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=ssl.raymii.org"

openssl req -new -x509 -nodes -out /etc/openldap/certs/${CERT_NAME} \
-keyout /etc/openldap/certs/${KEY_NAME} \
-days 365 -subj "${SUBJECT}"

chown -R ldap:ldap /etc/openldap/certs

echo "dn: cn=config
changetype: modify
replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/openldap/certs/${KEY_NAME}


dn: cn=config
changetype: modify
replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/openldap/certs/${CERT_NAME}" > certs.ldif

ldapmodify -Y EXTERNAL  -H ldapi:/// -f certs.ldif

rm *.ldif
