#!/bin/bash

echo "what do you want to do?"

options=(
  PDF
  WDMA
  Sleep
  Quit
)

select opt in "${options[@]}"
do
    case $opt in
        PDF)
          echo "yea buddy"
          ./pdf/init.sh
          ;;
        WDMA)
          echo "yarr"
          BUNDLE_GEMFILE=wdma/Gemfile bundle exec wdma/init.rb -w
          ;;
        Sleep)
          echo "..."
          osascript sleep.scpt
          ;;
        Quit)
          break
          ;;
        *) echo invalid option;;
    esac
done

