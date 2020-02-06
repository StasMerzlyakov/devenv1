#!/bin/bash

# ! sudo required
# domain: unit.organization.ru

[ -f ./variables ] || echo "file ./variables not exists" && exit 1
source ./variables
DOMAIN=$DOMAIN ADM_NAME=$ADM_NAME ADM_PASSWORD=$ADM_PASSWORD ./001_openldap.sh

