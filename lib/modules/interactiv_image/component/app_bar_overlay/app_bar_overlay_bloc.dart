import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../repository/interactive_image_repository.dart';
import 'app_bar_overlay_component.dart';
import 'app_bar_overlay_view_model.dart';

/// BLoC for the [AppBarOverlayComponent].
///
/// Exposes a [AppBarOverlayViewModel] for that component to use.
@injectable
class AppBarOverlayBloc {
  AppBarOverlayBloc(this._repository);

  final InteractiveImageRepository _repository;

  Stream<AppBarOverlayViewModel>? _viewModel;
  Stream<AppBarOverlayViewModel>? get viewModel => _viewModel;

  Stream<AppBarOverlayViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _repository.isAppBarVisible.map((isVisible) {
      return AppBarOverlayViewModel(isVisible: isVisible);
    });
  }
}
