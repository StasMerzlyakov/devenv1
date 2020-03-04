#!/bin/bash

ldapmodify -Y EXTERNAL -H ldapi:/// -f db.ldif
ldapmodify -D 'cn=ldapadm,dc=udmgazmyassbit,dc=ru' -w ldappass -f ./struct.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f access.ldif
ldapmodify -D 'cn=ldapadm,dc=udmgazmyassbit,dc=ru' -w ldappass -f ./redmine.ldif
