#!/bin/bash
source config

filename=$1

IFS=$'\n' read -d '' -r -a lucky_people < mail_list.txt

emails=$( printf ",%s" "${lucky_people[@]}" )
emails=${emails:1}

curl -s --user "api:$pdf_mail_mailgun_key" \
    $pdf_mail_mailgun_address \
    -F from=$pdf_mail_from \
    -F to=$emails \
    -F subject=$pdf_mail_subject \
    -F text=$pdf_mail_text \
    -F o:tag=$pdf_mail_mailgun_tag \
    -F attachment=@$destination$filename
