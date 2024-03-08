#!/bin/sh

bold=$(tput bold)
normal=$(tput sgr0)

printf "%s\n" "${bold}Update generated flutter files...${normal}"
dart run build_runner build --delete-conflicting-outputs
dart run gen_lang:generate --output-dir lib/i18n
printf "%s\n" "${bold}Done.${normal}"
