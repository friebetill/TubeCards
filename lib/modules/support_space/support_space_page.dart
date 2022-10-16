import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../main.dart';
import 'component/support_space/support_space_component.dart';
import 'repository/support_space_repository.dart';

class SupportSpacePage extends StatefulWidget {
  /// The page where users can support TubeCards.
  const SupportSpacePage({Key? key}) : super(key: key);

  static const String routeName = '/support-us';

  @override
  SupportSpacePageState createState() => SupportSpacePageState();
}

class SupportSpacePageState extends State<SupportSpacePage> {
  @override
  void initState() {
    super.initState();
    unawaited(loadPurchaserInfo());
  }

  @override
  Widget build(BuildContext context) => const SupportSpaceComponent();

  Future<void> loadPurchaserInfo() async {
    final purchaserInfo = await Purchases.getPurchaserInfo();
    getIt<SupportSpaceRepository>().purchaserInfo.add(purchaserInfo);
  }
}
