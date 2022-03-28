<p align="center">
  <a href="http://getspace.app/" target="blank"><img src="https://user-images.githubusercontent.com/10923085/126051087-9ac0dd5d-72df-41a6-8ebf-0e0e0e830ff2.png" width="320" alt="Space Logo" /></a>
</p>

<p align="center"><a href="http://getspace.app" target="blank">Space</a> build with <a href="https://flutter.dev" target="blank">Flutter</a>.</p>

## Update generated flutter files
#### From the console
```console
bash scripts/update_generated_files.sh
```

#### From Visual Studio Code
1. <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>p</kbd>
2. Tasks: Run task
3. Update generated flutter files

## Update metadata in Playstore
1. Make changes to the downloaded metadata, add images, screenshots and/or an APK
2. Go to the `android` folder
3. `fastlane supply`

## Testing with code coverage
This command runs the tests and stores the coverage info to `coverage/lcov.info`:
```sh
flutter test --coverage
```
To read this file install `lcov` (`brew install lcov`) and generate readable html files:
```sh
genhtml coverage/lcov.info -o coverage
open coverage/index.html
```

## Linter

Execute

```
pub global activate tuneup
```

to install tuneup. Also make sure you have `dart` in your path. It is located in your flutter install path at `bin/cache/dart-sdk/bin`.

Run

```
tuneup check
```

to run a linter check that also respects the `exclude` section from `analysis_options.yml`.

## Useful links
- [Debugging with wifi](https://medium.com/@_aakashpandey/develop-flutter-apps-for-android-over-wifi-fa49c76480d6)
