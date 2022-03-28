import 'dart:async';
import 'dart:io';

import 'package:golden_toolkit/golden_toolkit.dart';

// Ensures fonts are properly displayed for golden tests.
//
// DO NOT MOVE to another file.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
      await testMain();
    },
    config: GoldenToolkitConfiguration(
      primeAssets: (_) async {},
      // Since the Golden files are rendered slightly differently depending on
      // the OS, the files must always be compared on the same OS. Since the
      // automated tests run most cheapest on Linux, the tests are run on Linux.
      skipGoldenAssertion: () => !Platform.isLinux,
    ),
  );
}
