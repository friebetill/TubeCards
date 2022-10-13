import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../../../../i18n/i18n.dart';
import '../../../data/preferences/user_history.dart';
import '../../../utils/config.dart';
import '../../../utils/custom_navigator.dart';

class RateSpaceDialog extends StatelessWidget {
  const RateSpaceDialog(this._userHistory, {Key? key}) : super(key: key);

  final UserHistory _userHistory;

  static const _neverShowAgainDuration = Duration(days: 365 * 10);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).rateUs),
      contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      content: SizedBox(
        width: 250,
        child: Text(S.of(context).ifYouLikeSpaceText),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      actions: [
        Row(
          children: [
            TextButton(
              onPressed: _handleNeverButtonTap,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
              ),
              child: Text(S.of(context).never.toUpperCase()),
            ),
            const Spacer(),
            TextButton(
              onPressed: _handleLaterButtonTap,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).textTheme.bodyText2!.color,
              ),
              child: Text(S.of(context).later.toUpperCase()),
            ),
            TextButton(
              onPressed: _handleRateButtonTap,
              child: Text(S.of(context).rateNow.toUpperCase()),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNeverButtonTap() {
    _userHistory.nextShowRateAppDialogDate.setValue(
      DateTime.now().add(_neverShowAgainDuration),
    );
    CustomNavigator.getInstance().pop();
  }

  void _handleLaterButtonTap() {
    _userHistory.nextShowRateAppDialogDate.setValue(
      DateTime.now().add(const Duration(days: 14)),
    );
    CustomNavigator.getInstance().pop();
  }

  Future<void> _handleRateButtonTap() async {
    if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      unawaited(_userHistory.nextShowRateAppDialogDate.setValue(
        DateTime.now().add(const Duration(days: 1)),
      ));
      await InAppReview.instance.requestReview();
    } else if (Platform.isWindows) {
      await InAppReview.instance
          .openStoreListing(microsoftStoreId: microsoftStoreId);
      unawaited(
        _userHistory.nextShowRateAppDialogDate.setValue(
          DateTime.now().add(_neverShowAgainDuration),
        ),
      );
    }
    CustomNavigator.getInstance().pop();
  }
}
