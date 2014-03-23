#!/bin/bash
source ../config

# Desktop notification
/usr/local/bin/terminal-notifier \
  -subtitle "${1}" \
  -message 'Download Complete' \
  -title 'rTorrent'

# Email notification
curl -s --user "api:$torrent_mail_mailgun_key" \
    $torrent_mail_mailgun_address \
    -F from=$torrent_mail__from \
    -F to=$torrent_mail_to \
    -F subject="DL: ${1}" \
    -F text='Your download has completed.' \
    -F o:tag='download-complete' \
    -F o:tag='torrent'
