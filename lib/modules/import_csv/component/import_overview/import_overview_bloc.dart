import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../import_csv/data/csv_deck.dart';
import 'import_overview_component.dart';
import 'import_overview_view_model.dart';

/// BLoC for the [DataOverviewComponent].
@injectable
class DataOverviewBloc {
  Stream<DataOverviewViewModel>? _viewModel;
  Stream<DataOverviewViewModel>? get viewModel => _viewModel;

  Stream<DataOverviewViewModel> createViewModel(
    CSVDeck deck,
    VoidCallback importOverviewCallback,
  ) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel = Stream.value(DataOverviewViewModel(
      deck: deck,
      onStartImportTap: () => importOverviewCallback(),
    ));
  }
}
