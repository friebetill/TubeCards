import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/repositories/azure_image_search_repository.dart';
import '../../services/image_search_services/azure/azure_image_search_result.dart';
import '../../widgets/component/component_build_context.dart';
import '../../widgets/component/component_life_cycle_listener.dart';
import 'azure_image_search_view_model.dart';

@injectable
class AzureImageSearchBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  AzureImageSearchBloc({required this.imageRepository});

  final AzureImageSearchRepository imageRepository;

  Stream<AzureImageSearchViewModel>? _viewModel;
  Stream<AzureImageSearchViewModel>? get viewModel => _viewModel;

  final _searchResult = BehaviorSubject<AzureImageSearchResult?>.seeded(null);

  String? _lastSearchTerm;

  Stream<AzureImageSearchViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = _searchResult.map(_createViewModel);
  }

  AzureImageSearchViewModel _createViewModel(
    AzureImageSearchResult? searchResult,
  ) {
    return AzureImageSearchViewModel(
      addSearchTerm: _addSearchTerm,
      searchResult: searchResult,
      imagesPerPage: imageRepository.service.imagesPerPage,
    );
  }

  @override
  void dispose() {
    _searchResult.close();
    super.dispose();
  }

  Future<void> _addSearchTerm(String query) async {
    /// We need to check whether the user submitted a new search request.
    /// Unfortunately, there is no [onSearch] callback that could be used
    /// in order to be notified about each search event. Checking against
    /// the last search term is a work around to ensure that the same search
    /// term is not added multiple times since [buildResults] can be called
    /// more than once for the same search term.
    if (query == _lastSearchTerm) {
      return;
    }

    _lastSearchTerm = query;

    _searchResult.add(null);

    try {
      final result = await imageRepository.search(query);
      _searchResult.add(result);
    } on Exception catch (e) {
      _searchResult.addError(e);
    }
  }
}
