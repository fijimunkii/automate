#!/bin/bash
source config

function login() {
  postdata="log=$username&pwd=$password&wp-submit=Log%20In&redirect_to=wp-admin/"
  [ -e .cookies.txt ] && rm .cookies.txt

  curl  https://$domain/wp-login.php \
        --insecure \ 
        --connect-timeout 60 \ 
        --cookie-jar .cookies.txt \ 
        --data $postdata \
        --silent 
}

if curl -s -L https://$domain --cookie ".cookies.txt" | grep -q "Login"; then
  login
fi

# Uploads the torrent
curl -X POST -H "Content-Type: multipart/form-data; boundary=---------------------------139077927416152441701067983463" -d $'-----------------------------139077927416152441701067983463\r\nContent-Disposition: form-data; name="MAX_FILE_SIZE"\r\n\r\n2097152\r\n-----------------------------139077927416152441701067983463\r\n' \ 
  -F "torrent=@${1}" \
  https://$domain/u.php
