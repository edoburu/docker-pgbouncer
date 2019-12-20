#!/bin/bash
# A single script to generate an entry in for userlist.txt
# Usage:
#
# ./generate-userlist >> userlist.txt
# ./generate-userlist username >> userlist.txt
#

if [[ $# -eq 1 ]]; then
  USERNAME="$1"
else
  read -r -p "Enter username: " USERNAME
fi

read -r -s -p "Enter password: " PASSWORD
echo >&2

# Using openssl md5 to avoid differences between OSX and Linux (`md5` vs `md5sum`)
encrypted_password="md5$(printf "%s%s" "$PASSWORD" "$USERNAME" | openssl md5 -binary | xxd -p)"

echo "\"$USERNAME\" \"$encrypted_password\""
