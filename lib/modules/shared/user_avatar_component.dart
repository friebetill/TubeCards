import 'package:flutter/material.dart';

import '../../data/models/user.dart';

@immutable
class UserAvatarComponent extends StatelessWidget {
  const UserAvatarComponent({required this.user, Key? key}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: _getBackgroundColor(Theme.of(context).brightness),
      child: _buildChild(context),
    );
  }

  Text _buildChild(BuildContext context) {
    final firstName = user.firstName != null && user.firstName!.isNotEmpty
        ? user.firstName!
        : '?';

    return Text(
      firstName[0].toUpperCase(),
      style: TextStyle(color: Theme.of(context).colorScheme.background),
    );
  }

  Color _getBackgroundColor(Brightness brightness) {
    final colorMap = <int, Color Function(Brightness)>{
      0: (b) => Color(b == Brightness.light ? 0xFF55CDE4 : 0xFF4ECDE6),
      1: (b) => Color(b == Brightness.light ? 0xFFF89046 : 0xFFFA903E),
      2: (b) => Color(b == Brightness.light ? 0xFFFB66B5 : 0xFFFF63B8),
      3: (b) => Color(b == Brightness.light ? 0xFFEC6860 : 0xFFEE675C),
      4: (b) => Color(b == Brightness.light ? 0xFFFDC54A : 0xFFFCC934),
      5: (b) => Color(b == Brightness.light ? 0xFF5CB170 : 0xFF60B875),
      6: (b) => Color(b == Brightness.light ? 0xFFAF62EF : 0xFFAF5CF7),
    };

    return colorMap[user.id.hashCode % colorMap.length]!(brightness);
  }
}
