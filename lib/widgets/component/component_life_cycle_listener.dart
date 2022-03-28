import 'package:meta/meta.dart';

/// A mixin that allows a BLoC to receive lifecycle callbacks of its component.
mixin ComponentLifecycleListener {
  /// Called by the component when the component is disposed.
  @mustCallSuper
  void dispose() {}
}
