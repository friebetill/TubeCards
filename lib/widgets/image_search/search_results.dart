import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  const SearchResults({
    required this.images,
    this.branding,
    Key? key,
  }) : super(key: key);

  final List<Widget> images;

  final Widget? branding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, branding == null ? 16 : 0),
          child: GridView.count(
            physics: const ScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 5 / 3,
            shrinkWrap: true,
            children: images,
          ),
        ),
        if (branding != null) branding!,
      ],
    );
  }
}
