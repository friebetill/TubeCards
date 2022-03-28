import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../utils/socket_exception_extension.dart';
import '../../repository/interactive_image_repository.dart';
import 'interactive_image_component.dart';
import 'interactive_image_view_model.dart';

/// BLoC for the [InteractiveImageComponent].
///
/// Exposes a [InteractiveImageViewModel] for that component to use.
@injectable
class InteractiveImageBloc {
  InteractiveImageBloc(this._cacheManager, this._repository);

  final BaseCacheManager _cacheManager;
  final InteractiveImageRepository _repository;

  Stream<InteractiveImageViewModel>? _viewModel;
  Stream<InteractiveImageViewModel>? get viewModel => _viewModel;

  final _logger = Logger((InteractiveImageBloc).toString());

  Stream<InteractiveImageViewModel> createViewModel(String imageUrl) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    final isSvgImage = imageUrl.endsWith('svg');

    return _viewModel = Rx.combineLatest3(
      Stream.fromFuture(_cacheManager.getSingleFile(imageUrl))
          .doOnError((e, s) => _handleError(e, s, imageUrl)),
      Stream.value(imageUrl),
      Stream.value(isSvgImage),
      _createViewModel,
    );
  }

  InteractiveImageViewModel _createViewModel(
    File image,
    String imageUrl,
    bool isSvgImage,
  ) {
    return InteractiveImageViewModel(
      image: image,
      heroTag: '$imageUrl-hero',
      isSvgImage: isSvgImage,
      onTap: _handleTap,
    );
  }

  void _handleError(Object e, StackTrace? s, String imageUrl) {
    if (e is SocketException && (e.isNoInternet || e.isServerOffline)) {
      return;
    }
    _logger.severe('Exception when the image $imageUrl was shown.', e, s);
  }

  void _handleTap() {
    _repository.isAppBarVisible.add(!_repository.isAppBarVisible.value);
  }
}
