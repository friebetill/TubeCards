#!/bin/sh

bold=$(tput bold)
normal=$(tput sgr0)

printf "%s\n" "${bold}Fetching translations...${normal}"
flutter pub run lang_table:generate --platform=airTable --target=Flutter --input="$I18N_AIRTABLE_ADDRESS" --api-key="$I18N_AIRTABLE_KEY" > /dev/null

printf "%s\n" "${bold}Done.${normal}"

printf "%s\n" "${bold}Update language files...${normal}"
flutter packages pub run gen_lang:generate --output-dir lib/i18n
printf "%s\n" "${bold}Done.${normal}"
