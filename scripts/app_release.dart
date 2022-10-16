// ignore_for_file: avoid_print

import 'dart:io';

String version = '';
String code = '';

Future<void> main() async {
  version = await askWhichVersion();
  code = await askWhichCode();

  final procedures = [
    switchToDevBranch,
    updateVersionCodes,
    updateLinuxReleases,
    addReleaseNotes,
    pushChanges,
    updateMainBranch,
    createReleaseTag,
    rebuildGeneratedFiles,

    // iOS
    buildIOSArchive,
    distributeIOSArchive,

    // macOS
    buildMacOSArchive,
    distributMacOSSArchive,

    // Windows
    distributeWindowsBuild,

    // Linux
    calculateLinuxShasum,
    distributeLinuxArchive,

    switchToDevBranch,
  ];

  for (final procedure in procedures) {
    await procedure();
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

Future<void> switchToDevBranch() async {
  print('Press ENTER to switch to the `dev` branch and get the latest updates');
  await waitForEnter();
  await Process.run('git', ['checkout', 'dev']);
  await Process.run('git', ['pull']);
}

Future<void> updateVersionCodes() async {
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

  print((await Process.run('git', ['--no-pager', 'diff', 'pubspec.yaml']))
      .stdout);
  print('Press ENTER if the version updates in `pubspec.yaml` are correct:');
  await waitForEnter();
}

Future<void> updateLinuxReleases() async {
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

  print((await Process.run('git', [
    '--no-pager',
    'diff',
    'linux/flathub/app.getspace.Space.metainfo.xml'
  ]))
      .stdout);
  print(
      'Press ENTER if the version update in `linux/flathub/app.getspace.Space.metainfo.xml` is correct:');
  await waitForEnter();
}

Future<void> addReleaseNotes() async {
  print('Add the release notes in:');
  print('  lib/utils/release_notes.dart');
  print('  android/whats_new/whatsnew-en-US');
  await waitForEnter();
}

Future<void> pushChanges() async {
  print('Press ENTER to commit and push the files:');
  await waitForEnter();
  await Process.run('git', [
    'add',
    'pubspec.yaml',
    'lib/utils/release_notes.dart',
    'linux/flathub/app.getspace.Space.metainfo.xml',
    'android/whats_new/whatsnew-en-US'
  ]);
  await Process.run('git', ['commit', '-m', 'Bump to $version']);
  await Process.run('git', ['push']);
}

Future<void> updateMainBranch() async {
  print('Press ENTER to switch to the `main` branch '
      'and get the latest dev updates');
  await waitForEnter();
  await Process.run('git', ['checkout', 'main']);
  await Process.run('git', ['pull', 'origin', 'dev']);
  await Process.run('git', ['push']);
}

Future<void> createReleaseTag() async {
  print('Press ENTER to create a release tag');
  await waitForEnter();
  await Process.run('git', ['tag', version]);
  await Process.run('git', ['push', 'origin', version]);
}

Future<void> rebuildGeneratedFiles() async {
  print('Press ENTER to update latest packages and '
      'rebuild the generated files');
  await waitForEnter();
  await Process.run('flutter', ['pub', 'get']);
  await Process.run('./scripts/update_generated_files.sh', []);
  await Process.run('./scripts/update_language_files.sh', []);
}

Future<void> buildIOSArchive() async {
  print('Press ENTER to build the iOS build archive');
  await waitForEnter();
  // This refreshes the release mode configuration in Xcode (updates version
  // and number, maybe more)
  await Process.run(
      'flutter', ['build', 'ipa', '--release', '--flavor', 'prod']);

  // Source: [Build and release an iOS app](https://flutter.dev/docs/deployment/ios#create-a-build-archive)
}

Future<void> distributeIOSArchive() async {
  print('Distribute the iOS archive:');
  print('  Open `build/ios/archive/Runner.xcarchive` in Xcode');
  print('  Click "Distribute App".');
  print(
    '  In 30 minutes you will receive an email that the release is available '
    'in the test flight.',
  );
  await waitForEnter();
}

Future<void> buildMacOSArchive() async {
  print('Press ENTER to build the macOS archive');
  await waitForEnter();
  await Process.run(
      'flutter', ['build', 'macos', '--dart-define', 'app.flavor=prod']);
}

Future<void> distributMacOSSArchive() async {
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

Future<void> distributeWindowsBuild() async {
  print('Distribute the Windows app:');
  print(
    '  Go to https://github.com/friebetill/tubecards/releases/tag/$version',
  );
  print('  Download space_$version.msix');
  print('  Go to `https://partner.microsoft.com/` and publish the file.');
  await waitForEnter();
}

Future<void> calculateLinuxShasum() async {
  print('Press ENTER to calculate the shasum of the Linux archive');
  await waitForEnter();

  await Process.run('j', ['flathub']);
  print('Wait until the checksum of the Linux release has been calculated');

  final releaseUrl =
      'https://space-linux.s3.eu-west-1.amazonaws.com/releases/space_$version.tar.xz';
  await Process.run('curl', ['-O', releaseUrl]);
  final result =
      await Process.run('shasum', ['-a', '256', 'space_$version.tar.xz']);
  final shasum = (result.stdout as String).split(' ')[0];
  await Process.run('rm', ['space_$version.tar.xz']);

  final file = File('app.getspace.Space.json');
  final lines = (await file.readAsLines()).toList();

  final urlIndex = lines.indexWhere((l) => l.startsWith('          "url": '));
  lines
    ..removeAt(urlIndex)
    ..insert(urlIndex, '          "url": "$releaseUrl",');

  final sha256Index =
      lines.indexWhere((l) => l.startsWith('          "sha256":'));
  lines
    ..removeAt(sha256Index)
    ..insert(sha256Index, '          "sha256": "$shasum",');

  await file.writeAsString('${lines.join('\n')}\n');

  print((await Process.run(
          'git', ['--no-pager', 'diff', 'app.getspace.Space.json']))
      .stdout);
  print('Press ENTER if the version updates in '
      '`app.getspace.Space.json` are correct:');
  await waitForEnter();
}

Future<void> distributeLinuxArchive() async {
  print('Press ENTER to distribute the Linux archive');
  await waitForEnter();
  await Process.run('git', ['add', 'app.getspace.Space.json']);
  await Process.run('git', ['commit', '-m', '"Release $version"']);
  await Process.run('git', ['push']);
}

Future<void> waitForEnter() async {
  while (stdin.readLineSync(retainNewlines: true) != '\n') {}
}
