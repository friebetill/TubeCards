import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import '../../../../widgets/simple_skeleton.dart';
import '../../../import_csv/data/csv_card.dart';
import '../../../import_csv/data/csv_deck.dart';
import 'import_overview_bloc.dart';
import 'import_overview_view_model.dart';

class DataOverviewComponent extends StatelessWidget {
  const DataOverviewComponent({
    required this.appBarTitle,
    required this.deck,
    required this.importOverviewCallback,
    Key? key,
  }) : super(key: key);

  final String appBarTitle;
  final CSVDeck deck;
  final VoidCallback importOverviewCallback;

  @override
  Widget build(BuildContext context) {
    return Component<DataOverviewBloc>(
      createViewModel: (bloc) => bloc.createViewModel(
        deck,
        importOverviewCallback,
      ),
      builder: (context, bloc) {
        return StreamBuilder<DataOverviewViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SimpleSkeleton(appBarTitle: appBarTitle);
            }

            return _DataOverviewView(
              viewModel: snapshot.data!,
              appBarTitle: appBarTitle,
            );
          },
        );
      },
    );
  }
}

@immutable
class _DataOverviewView extends StatelessWidget {
  const _DataOverviewView({
    required this.viewModel,
    required this.appBarTitle,
    Key? key,
  }) : super(key: key);

  final DataOverviewViewModel viewModel;
  final String appBarTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeckTile(context),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemExtent: 60,
              itemCount: viewModel.deck.cards.length,
              itemBuilder: (_, index) => _buildCardTile(
                context,
                viewModel.deck.cards[index],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildStartImportFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDeckTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(
          viewModel.deck.name,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Text(
          S.of(context).cardsWithNumber(viewModel.deck.cards.length),
        ),
      ),
    );
  }

  Widget _buildCardTile(BuildContext context, CSVCard card) {
    return ListTileAdapter(
      child: ListTile(
        title: Text(
          // The text fades out to the bottom if there is a linebreak before the
          // end of line is reached. To prevent this we remove the linebreak.
          card.front.split('\n').first,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        subtitle: Text(
          // The text fades out to the bottom if there is a linebreak before the
          // end of line is reached. To prevent this we remove the linebreak.
          card.back.split('\n').first,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
      ),
    );
  }

  Widget _buildStartImportFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: viewModel.onStartImportTap,
      icon: const Icon(Icons.upload_outlined),
      label: Text(
        S.of(context).startImport.toUpperCase(),
        overflow: TextOverflow.fade,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }
}
