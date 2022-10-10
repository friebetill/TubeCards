echo ^<ESC^>[1m [1mFetching translations...[0m
flutter pub run lang_table:generate --platform=airTable --target=Flutter --input=https://api.airtable.com/v0/app6dkbYXMccUCZb1/i18n --api-key=keyRYfny0HikUbPSL
echo ^<ESC^>[1m [1mDone.[0m

echo ^<ESC^>[1m [1mUpdate generated flutter files...[0m
flutter pub run build_runner build --delete-conflicting-outputs
flutter packages pub run gen_lang:generate --output-dir lib/i18n
echo ^<ESC^>[1m [1mDone.[0m
