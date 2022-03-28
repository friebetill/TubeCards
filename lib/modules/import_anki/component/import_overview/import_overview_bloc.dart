import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/snackbar.dart';
import '../../../../widgets/component/component_build_context.dart';
import '../../../../widgets/component/component_life_cycle_listener.dart';
import '../../data/anki_deck.dart';
import '../../data/anki_package.dart';
import 'import_overview_component.dart';
import 'import_overview_view_model.dart';

/// BLoC for the [ImportOverviewComponent].
@injectable
class ImportOverviewBloc
    with ComponentBuildContext, ComponentLifecycleListener {
  Stream<ImportOverviewViewModel>? _viewModel;
  Stream<ImportOverviewViewModel>? get viewModel => _viewModel;

  late final BehaviorSubject<BuiltMap<int, bool>> _deckIdToIsActiveStream;

  Stream<ImportOverviewViewModel> createViewModel(
    AnkiPackage package,
    Function(AnkiPackage) importOverviewCallback,
  ) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    _deckIdToIsActiveStream = BehaviorSubject.seeded(BuiltMap<int, bool>(
      {for (var deck in package.decks) deck.id: true},
    ));

    return _viewModel = _deckIdToIsActiveStream.map((activeDecks) {
      return ImportOverviewViewModel(
        decks: package.decks,
        activeDecks: activeDecks,
        deckCount: package.decks.length,
        cardCount: package.decks.fold<int>(0, (p, d) => p + d.cards.length),
        onToggleActiveDeckTap: _handleToggleActiveDeckTap,
        onStartImportTap: () =>
            _handleStartImportTap(importOverviewCallback, package),
      );
    });
  }

  @override
  void dispose() {
    _deckIdToIsActiveStream.close();
    super.dispose();
  }

  void _handleToggleActiveDeckTap(bool isActive, int deckID) {
    final deckToIDMap = _deckIdToIsActiveStream.value
        .rebuild((builder) => builder[deckID] = isActive);
    _deckIdToIsActiveStream.add(deckToIDMap);
  }

  void _handleStartImportTap(
    Function(AnkiPackage) importOverviewCallback,
    AnkiPackage package,
  ) {
    final isAtLeastOneDeckActive =
        _deckIdToIsActiveStream.value.containsValue(true);
    if (isAtLeastOneDeckActive) {
      final activeDecks = <AnkiDeck>[];

      _deckIdToIsActiveStream.value.forEach((id, isActive) {
        if (isActive) {
          activeDecks.add(package.decks.singleWhere((deck) => deck.id == id));
        }
      });

      importOverviewCallback(AnkiPackage(
        decks: activeDecks,
        jsonMedia: package.jsonMedia,
        extractionPath: package.extractionPath,
      ));
    } else {
      ScaffoldMessenger.of(context).showErrorSnackBar(
        theme: Theme.of(context),
        text: S.of(context).selectOneDeckText,
      );
    }
  }
}
