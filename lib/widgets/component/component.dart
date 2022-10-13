import 'package:flutter/widgets.dart';

import '../../main.dart';
import '../component/component_life_cycle_listener.dart';
import 'component_build_context.dart';
import 'component_dialog.dart';

// Bloc needs to extend Object to be retrievable by GetIt.
class Component<Bloc extends Object> extends StatefulWidget {
  const Component({
    required this.builder,
    required this.createViewModel,
    this.keepAlive = true,
    Key? key,
  }) : super(key: key);

  final Widget Function(BuildContext context, Bloc bloc) builder;

  final ValueChanged<Bloc> createViewModel;

  final bool keepAlive;

  @override
  State<StatefulWidget> createState() => _ComponentState<Bloc>();
}

class _ComponentState<Bloc extends Object> extends State<Component<Bloc>>
    with AutomaticKeepAliveClientMixin<Component<Bloc>> {
  Bloc? bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Build the bloc using GetIt dependency injection.
    if (bloc == null) {
      bloc = getIt<Bloc>();

      if (bloc is ComponentBuildContext) {
        (bloc! as ComponentBuildContext).context = context;
      }

      if (bloc is ComponentDialog) {
        (bloc! as ComponentDialog).onDialog();
      }

      widget.createViewModel(bloc!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.builder(context, bloc!);
  }

  @override
  void dispose() {
    if (bloc != null && bloc is ComponentLifecycleListener) {
      (bloc! as ComponentLifecycleListener).dispose();
    }
    super.dispose();
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
