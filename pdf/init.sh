#!/bin/bash
source config

monitor="$root/Monitor"
archive="$root/Archive/"
output="$root/Processed/"
tempdir="$root/temp/"
tempfile="$tempdir/temp.pdf"

echo Scanning...

shopt -s nullglob
pdf_files=( "$monitor"/* )

for pdf_file in "${pdf_files[@]}"
do
    page_number=${pdf_file:56:2}  
    filename="${pdf_file:41:14}.pdf"

    echo Preparing $filename
    convert -density 300 -units PixelsPerInch -define pdf:use-trimbox=true \
      $pdf_file -fill white -draw "rectangle 225,0 2000,400" $tempfile
    gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.2 -dPDFSETTINGS=/ebook \
      -dHaveTransparency=false -dNOPAUSE -dQUIET -dBATCH \
      -dFirstPage=$page_number -sOutputFile=$output$filename $tempfile

    echo Cleaning up files.
    rm $tempfile
    mv $pdf_file $archive
    mv $output$filename $destination
 
    echo Preparing torrent.
    mktorrent -l 21 -p -a http://i.make.torrents/say-what \
      -c 'Share the knowledge.' \
      $destination$filename -o "${tempdir}${filename}.torrent"

#   echo Uploading torrent.
#   ./upload_torrent.rb "${filename}.torrent"

   echo Mailing out list.
   ./mail.sh $filename
done

echo Done.
