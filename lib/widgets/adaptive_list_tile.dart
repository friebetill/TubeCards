import 'package:flutter/material.dart';

import '../utils/text_size.dart';

class AdaptiveListTile extends StatefulWidget {
  const AdaptiveListTile({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Widget leadingIcon;

  final VoidCallback onTap;

  @override
  AdaptiveListTileState createState() => AdaptiveListTileState();
}

class AdaptiveListTileState extends State<AdaptiveListTile> {
  var _isThreeLine = true;

  @override
  Widget build(BuildContext context) {
    final subtitleSize = textSize(widget.subtitle);

    return ListTile(
      title: Text(widget.title),
      subtitle: LayoutBuilder(builder: (context, constraints) {
        final largeSubtitle = subtitleSize.width > constraints.maxWidth;
        if (_isThreeLine != largeSubtitle) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() => _isThreeLine = false);
          });
        }

        return Text(widget.subtitle);
      }),
      isThreeLine: _isThreeLine,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: widget.leadingIcon,
      ),
      onTap: widget.onTap,
    );
  }
}
