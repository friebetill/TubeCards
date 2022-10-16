import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:timelines/timelines.dart';

import '../../../i18n/i18n.dart';
import '../../../utils/assets.dart';
import '../../../utils/release_notes.dart';

class AboutDialog extends StatefulWidget {
  const AboutDialog({Key? key}) : super(key: key);

  @override
  AboutDialogState createState() => AboutDialogState();
}

class AboutDialogState extends State<AboutDialog> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() => _version = packageInfo.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      scrollable: true,
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.4,
        width: 600,
        child: ListView(
          children: [
            Text(S.of(context).aboutSpaceText),
            const SizedBox(height: 24),
            Text(
              S.of(context).changelog,
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16),
            Timeline.tileBuilder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              theme: _buildTimeLineTheme(),
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.before,
                itemCount: releaseNotes.length,
                contentsBuilder: _buildContent,
                indicatorBuilder: _buildIndicator,
                connectorBuilder: _buildConnector,
              ),
            ),
          ],
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IconTheme(
          data: Theme.of(context).iconTheme,
          child: SvgPicture.asset(
            Assets.images.brandLogo,
            width: 48,
            height: 48,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ListBody(
            children: <Widget>[
              Text('TubeCards', style: Theme.of(context).textTheme.headline5),
              Text(_version, style: Theme.of(context).textTheme.bodyText2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, int index) {
    final version = releaseNotes[index].version;
    final releaseNote = releaseNotes[index].releaseNote;
    final date = releaseNotes[index].date;
    final convertedDateTime = '${date.year.toString()}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              style: Theme.of(context).textTheme.headline6!,
              children: [
                TextSpan(text: version),
                const TextSpan(text: ' '),
                TextSpan(
                  text: convertedDateTime,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          ),
          if (releaseNote.isNotEmpty) const SizedBox(height: 8),
          if (releaseNote.isNotEmpty)
            Text(
              releaseNote,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  TimelineThemeData _buildTimeLineTheme() {
    return TimelineThemeData(
      nodePosition: 0,
      indicatorTheme: const IndicatorThemeData(position: 0),
    );
  }

  Widget _buildIndicator(BuildContext context, int index) {
    return OutlinedDotIndicator(
      size: 24,
      borderWidth: 3,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFF666666)
          : const Color(0xFF999999),
    );
  }

  Widget _buildConnector(BuildContext context, int index, ConnectorType type) {
    return SolidLineConnector(
      thickness: 2.5,
      color: Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFAAAAAA)
          : const Color(0xFF555555),
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: () {
          showLicensePage(
            context: context,
            applicationName: 'TubeCards',
            applicationVersion: _version,
            applicationIcon: SvgPicture.asset(
              Assets.images.brandLogo,
              width: 48,
              height: 48,
            ),
          );
        },
        child: Text(
          MaterialLocalizations.of(context).viewLicensesButtonLabel,
        ),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).close.toUpperCase()),
      ),
    ];
  }
}
