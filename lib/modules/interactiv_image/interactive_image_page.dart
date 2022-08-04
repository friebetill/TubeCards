import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import 'component/app_bar_overlay/app_bar_overlay_component.dart';
import 'component/interactive_image/interactive_image_component.dart';
import 'repository/interactive_image_repository.dart';

/// The screen on which the profile of the user and the settings of the user
/// are displayed.
class InteractiveImagePage extends StatefulWidget {
  /// Creates a new [InteractiveImagePage] instance.
  const InteractiveImagePage({required this.imageUrl, Key? key})
      : super(key: key);

  /// The name of the route to the [InteractiveImagePage] screen.
  static const routeName = '/interactive-image';

  /// The url of the image.
  final String imageUrl;

  @override
  InteractiveImagePageState createState() => InteractiveImagePageState();
}

class InteractiveImagePageState extends State<InteractiveImagePage> {
  @override
  void initState() {
    super.initState();
    if (getIt.isRegistered<InteractiveImageRepository>()) {
      getIt.unregister<InteractiveImageRepository>();
    }
    getIt.registerSingleton(InteractiveImageRepository());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: <Widget>[
            InteractiveImageComponent(widget.imageUrl),
            const AppBarOverlayComponent(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    getIt.get<InteractiveImageRepository>().dispose();
    getIt.unregister<InteractiveImageRepository>();
    super.dispose();
  }
}
