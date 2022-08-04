import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/custom_navigator.dart';
import '../../../utils/os_icons.dart';
import '../../../utils/snackbar.dart';

final _androidVersionURL = Uri.https(
    'play.google.com', '/store/apps/details', {'id': 'com.space.space'});
final _appleVersionURL =
    Uri.https('apps.apple.com', '/us/app/space-spaced-repetition/id1546202212');
final _windowsVersionURL =
    Uri.https('microsoft.com', '/en-us/p/space-spaced-repetition/9n2zrwbkjkt9');
final _linuxVersionURL =
    Uri.https('flathub.org', '/apps/details/app.getspace.Space');

class OtherPlatformsDialog extends StatelessWidget {
  const OtherPlatformsDialog({Key? key}) : super(key: key);

  /// Dialog asking to confirm the logout despite unsynchronized data.
  ///
  /// Returns true if the user wants to log out and false if the user
  /// doesn't want to log out.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).spaceIsOnThesePlatforms),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (!Platform.isWindows)
              ListTile(
                leading: const Icon(OSIcons.windows, size: 48),
                onTap: () => _launchURL(_windowsVersionURL, context),
                title: const Text('Windows'),
              ),
            ListTile(
              leading: const Icon(OSIcons.apple, size: 48),
              onTap: () => _launchURL(_appleVersionURL, context),
              title: const Text('Apple'),
            ),
            if (!Platform.isLinux)
              ListTile(
                leading: const Icon(OSIcons.linux, size: 48),
                onTap: () => _launchURL(_linuxVersionURL, context),
                title: const Text('Linux'),
              ),
            if (!Platform.isAndroid)
              ListTile(
                leading: const Icon(OSIcons.android, size: 48),
                onTap: () => _launchURL(_androidVersionURL, context),
                title: const Text('Android'),
              ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: CustomNavigator.getInstance().pop,
          child: Text(S.of(context).close.toUpperCase()),
        ),
      ],
    );
  }

  Future<void> _launchURL(Uri url, BuildContext context) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).errorOpenPageText(url),
      );
      throw Exception(S.of(context).couldNotLaunchURL(url));
    }
  }
}
