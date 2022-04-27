// ignore_for_file: avoid_print

import 'dart:io';

Future<void> main() async {
  final version = await askWhichVersion();
  final code = await askWhichCode();

  final procedures = [
    // Kickstart GitHub actions to build the release
    switchToDevBranch,
    updateVersionCodes,
    updateLinuxReleases,
    addReleaseNotes,
    pushChanges,
    updateMainBranch,
    createReleaseTag,

    // Prepare local files for builds
    rebuildGeneratedFiles,

    // Build the iOS app
    buildIOSArchive,
    distributeIOSArchive,

    // Build the MacOS app
    buildMacOSArchive,
    distributMacOSSArchive,

    // Distribute the Windows app
    distributeWindowsBuild,

    // Distribute the Linux app
    goToTheFlathubFolder,
    addTheNewRelease,
    distributeLinuxBuild,
  ];

  for (final procedure in procedures) {
    await procedure(version: version, code: code);
  }

  print('Done.');
}

Future<String> askWhichVersion() async {
  final file = File('pubspec.yaml');
  final lines = (await file.readAsLines()).toList();
  final versionAndCode =
      lines.singleWhere((l) => l.startsWith('version: ')).split(': ')[1];
  final version = versionAndCode.split('+')[0];

  print('What is the new version? The current version is "$version".');

  String? reply;
  while (reply == null) {
    reply = stdin.readLineSync();
  }

  return reply;
}

Future<String> askWhichCode() async {
  final file = File('pubspec.yaml');
  final lines = (await file.readAsLines()).toList();
  final versionAndCode =
      lines.singleWhere((l) => l.startsWith('version: ')).split(': ')[1];
  final code = versionAndCode.split('+')[1];

  print('What is the new version? The current code is "$code".');

  String? reply;
  while (reply == null) {
    reply = stdin.readLineSync();
  }

  return reply;
}

Future<void> switchToDevBranch({
  required String version,
  required String code,
}) async {
  print('Switch to the `dev` branch and get the latest updates:');
  print('  git checkout dev');
  print('  git pull');
  print('Press ENTER to continue:');
  await waitForEnter();
}

Future<void> updateVersionCodes({
  required String version,
  required String code,
}) async {
  final file = File('pubspec.yaml');
  final lines = (await file.readAsLines()).toList();

  final versionIndex = lines.indexWhere((l) => l.startsWith('version: '));
  lines
    ..removeAt(versionIndex)
    ..insert(versionIndex, 'version: $version+$code');

  final msixIndex = lines.indexWhere((l) => l.startsWith('  msix_version: '));
  lines
    ..removeAt(msixIndex)
    ..insert(msixIndex, '  msix_version: $version.0');

  await file.writeAsString('${lines.join('\n')}\n');

  print('Verify automatic version update in `pubspec.yaml`:');
  await waitForEnter();
}

Future<void> updateLinuxReleases({
  required String version,
  required String code,
}) async {
  final today = DateTime.now();
  final dateSlug = '${today.year.toString()}-'
      '${today.month.toString().padLeft(2, '0')}-'
      '${today.day.toString().padLeft(2, '0')}';

  final file = File('linux/flathub/app.getspace.Space.metainfo.xml');
  final lines = (await file.readAsLines()).toList();

  final releasesIndex = lines.indexWhere((l) => l.startsWith('  <releases>'));
  lines.insert(
    releasesIndex + 1,
    '    <release version="$version" date="$dateSlug"/>',
  );

  await file.writeAsString('${lines.join('\n')}\n');

  print(
    'Verify automatic version update `linux/flathub/app.getspace.Space.metainfo.xml`:',
  );
  await waitForEnter();
}

Future<void> addReleaseNotes({
  required String version,
  required String code,
}) async {
  print('Add the release notes in:');
  print('  lib/utils/release_notes.dart');
  print('  android/whats_new/whatsnew-en-US');
  await waitForEnter();
}

Future<void> pushChanges({
  required String version,
  required String code,
}) async {
  print('Commit and push the changes:');
  print('    git add pubspec.yaml lib/utils/release_notes.dart '
      'linux/flathub/app.getspace.Space.metainfo.xml android/whats_new/whatsnew-en-US');
  print('    git commit -m "Bump to $version"');
  print('    git push');
  await waitForEnter();
}

Future<void> updateMainBranch({
  required String version,
  required String code,
}) async {
  print('Switch to the `main` branch and get the latest dev updates:');
  print('  git checkout main');
  print('  git pull origin dev');
  print('  git push');
  await waitForEnter();
}

Future<void> createReleaseTag({
  required String version,
  required String code,
}) async {
  print('Create a release tag:');
  print('  git tag $version');
  print('  git push origin $version');
  await waitForEnter();
}

Future<void> rebuildGeneratedFiles({
  required String version,
  required String code,
}) async {
  print('Update latest packages and rebuild the generated files:');
  print('  flutter pub get');
  print('  ./scripts/update_generated_files.sh');
  print('  ./scripts/update_language_files.sh');

  await waitForEnter();
}

Future<void> buildIOSArchive({
  required String version,
  required String code,
}) async {
  print('Build the iOS build archive:');
  // This refreshes the release mode configuration in Xcode (updates version
  // and number, maybe more)
  print('  flutter build ipa --release --flavor prod');
  await waitForEnter();

  // Source: [Build and release an iOS app](https://flutter.dev/docs/deployment/ios#create-a-build-archive)
}

Future<void> distributeIOSArchive({
  required String version,
  required String code,
}) async {
  print('Distribute the iOS archive:');
  print('  Open `build/ios/archive/Runner.xcarchive` in Xcode');
  print('  Click "Distribute App".');
  print(
    '  In 30 minutes you will receive an email that the release is available '
    'in the test flight.',
  );
  await waitForEnter();
}

Future<void> buildMacOSArchive({
  required String version,
  required String code,
}) async {
  print('Build the MacOS archive:');
  print('  flutter build macos --dart-define app.flavor=prod');
  await waitForEnter();
}

Future<void> distributMacOSSArchive({
  required String version,
  required String code,
}) async {
  print('Distribute the MacOS archive:');
  print('  Open `macos/Runner.xcworkspace` with Xcode');
  print('  Select `Product` -> `Archive`');
  print('  Click "Distribute App".');
  print(
    '  In 30 minutes you will receive an email that the release is available '
    'in the test flight.',
  );
  await waitForEnter();
}

Future<void> distributeWindowsBuild({
  required String version,
  required String code,
}) async {
  print('Distribute the Windows app:');
  print(
    '  Go to https://github.com/friebetill/space/releases/tag/$version',
  );
  print('  Download space_$version.msix');
  print('  Go to `https://partner.microsoft.com/` and publish the file.');
  await waitForEnter();
}

Future<void> goToTheFlathubFolder({
  required String version,
  required String code,
}) async {
  print('Go to the Flathub repository:');
  print('  j flathub');
  await waitForEnter();
}

Future<void> addTheNewRelease({
  required String version,
  required String code,
}) async {
  print('Wait until the checksum of the Linux release has been calculated');
  await Process.run('curl', [
    '-O',
    'https://space-linux.s3.eu-west-1.amazonaws.com/releases/space_$version.tar.xz',
  ]);
  final result =
      await Process.run('shasum', ['-a', '256', 'space_$version.tar.xz']);
  final shasum = (result.stdout as String).split(' ')[0];
  await Process.run('rm', ['space_$version.tar.xz']);

  print('Add the new release to `app.getspace.Space.json`');
  print(
    '  "url": "https://space-linux.s3.eu-west-1.amazonaws.com/releases/space_$version.tar.xz",',
  );
  print('  "sha256": "$shasum",');
  await waitForEnter();
}

Future<void> distributeLinuxBuild({
  required String version,
  required String code,
}) async {
  print('Distribute the Linux version');
  print('  git add app.getspace.Space.json');
  print('  git commit -m "Release $version"');
  print('  git push');
  await waitForEnter();
}

Future<void> waitForEnter() async {
  while (stdin.readLineSync(retainNewlines: true) != '\n') {}
}
