import 'package:flutter/material.dart';

import 'component/manage_members/manage_members_component.dart';

class ManageMembersPage extends StatelessWidget {
  const ManageMembersPage(this.deckId, {Key? key}) : super(key: key);

  /// The name of the route to the [ManageMembersPage] screen.
  static const String routeName = '/deck/manage-members';

  final String deckId;

  @override
  Widget build(BuildContext context) => ManageMembersComponent(deckId);
}
