import 'package:flutter/material.dart';

class SimpleSkeleton extends StatelessWidget {
  const SimpleSkeleton({
    this.appBarTitle = '',
    Key? key,
  }) : super(key: key);

  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        elevation: 0,
      ),
      body: Container(),
    );
  }
}
