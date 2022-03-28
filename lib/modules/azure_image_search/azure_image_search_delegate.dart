import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../i18n/i18n.dart';
import '../../services/image_search_services/azure/azure_image_search_result_item.dart';
import '../../utils/assets.dart';
import '../../utils/responsiveness/breakpoints.dart';
import '../../widgets/component/component.dart';
import '../../widgets/image_placeholder.dart';
import '../../widgets/image_search/image_search_result_tile.dart';
import '../../widgets/image_search/search_results.dart';
import '../../widgets/image_search/search_status.dart';
import '../home/component/utils/error_indicator.dart';
import 'azure_image_search_bloc.dart';
import 'azure_image_search_view_model.dart';

class AzureImageSearchDelegate<T extends AzureImageSearchResultItem?>
    extends SearchDelegate<T?> {
  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      key: const ValueKey('back-button'),
      color: Theme.of(context).appBarTheme.foregroundColor,
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear_outlined),
        onPressed: () => query = '',
        color: Theme.of(context).appBarTheme.foregroundColor,
        tooltip: S.of(context).clearQuery,
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildComponent(
      builder: (viewModel) {
        if (query.isEmpty) {
          return Container();
        }

        viewModel.addSearchTerm(query);

        if (viewModel.searchResult == null) {
          return SearchResults(
            images: List.generate(
              viewModel.imagesPerPage,
              (_) => ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: const ImagePlaceholder(),
              ),
            ),
          );
        }

        if (viewModel.searchResult!.items.isEmpty) {
          return SearchStatus(
            S.of(context).weHaventFoundAnyImages,
            Icons.assignment_outlined,
          );
        }

        return LayoutBuilder(builder: (context, constraints) {
          return SearchResults(
            images: viewModel.searchResult!.items
                .map((i) => ImageSearchResultTile(
                      item: i,
                      showThumbnail:
                          constraints.maxWidth < Breakpoint.mobileToLarge,
                    ))
                .toList(),
            branding: _buildBranding(context),
          );
        });
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildComponent(builder: (viewModel) => Container());
  }

  Widget _buildComponent({
    required Widget Function(AzureImageSearchViewModel) builder,
  }) {
    return Component<AzureImageSearchBloc>(
      key: const ValueKey('ImageSearchComponent<AzureImageSearchResult>'),
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<AzureImageSearchViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: ErrorIndicator(snapshot.error!));
            }
            if (snapshot.data == null) {
              return Container();
            }

            return builder(snapshot.data!);
          },
        );
      },
    );
  }

  /// Builds a Bing branding in accordance to https://bit.ly/3cR2BqG.
  Widget _buildBranding(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Powered by', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 7),
          SvgPicture.asset(
            Assets.images.bingLogo,
            height: 15,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.grey[700],
          ),
        ],
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);
}
