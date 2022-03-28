import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../data/anki_deck.dart';
import '../../data/anki_package.dart';
import 'import_overview_bloc.dart';
import 'import_overview_view_model.dart';

class ImportOverviewComponent extends StatelessWidget {
  const ImportOverviewComponent(
    this.package,
    this.importOverviewCallback, {
    Key? key,
  }) : super(key: key);

  final AnkiPackage package;
  final Function(AnkiPackage) importOverviewCallback;

  @override
  Widget build(BuildContext context) {
    return Component<ImportOverviewBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        package,
        importOverviewCallback,
      ),
      builder: (context, bloc) {
        return StreamBuilder<ImportOverviewViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: S.of(context).importFromAnki);
            }

            return _ImportOverviewView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ImportOverviewView extends StatelessWidget {
  const _ImportOverviewView({required this.viewModel, Key? key})
      : super(key: key);

  final ImportOverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).importFromAnki),
          elevation: 0,
          leading: IconButton(
            icon: const BackButtonIcon(),
            onPressed: CustomNavigator.getInstance().pop,
            tooltip: backTooltip(context),
          ),
        ),
        body: _buildDeckList(context),
        floatingActionButton: _buildStartImportFloatingActionButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildDeckList(BuildContext context) {
    final headerColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            S.of(context).decksWithCount(viewModel.deckCount).toUpperCase(),
            style: TextStyle(
              color: headerColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemExtent: 60,
            itemCount: viewModel.deckCount,
            itemBuilder: (_, index) => _buildDeckTile(
              context,
              viewModel.decks![index],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeckTile(BuildContext context, AnkiDeck deck) {
    return ListTileAdapter(
      child: SwitchListTile(
        title: Text(
          deck.name,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Text(S.of(context).cardsWithNumber(deck.cards.length)),
        value: viewModel.activeDecks[deck.id]!,
        onChanged: (isActive) =>
            viewModel.onToggleActiveDeckTap(isActive, deck.id),
      ),
    );
  }

  Widget _buildStartImportFloatingActionButton(BuildContext context) {
    final isAtLeastOneDeckActive = viewModel.activeDecks.containsValue(true);

    return FloatingActionButton.extended(
      onPressed: viewModel.onStartImportTap,
      icon: const Icon(Icons.upload_outlined),
      label: Text(
        S.of(context).startImport.toUpperCase(),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
      foregroundColor: isAtLeastOneDeckActive
          ? Theme.of(context).colorScheme.onPrimary
          : Theme.of(context).disabledColor,
      backgroundColor: isAtLeastOneDeckActive
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).brightness == Brightness.light
              ? Colors.grey.shade100
              : const Color(0xFF2A2E35),
    );
  }
}
