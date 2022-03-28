library image_search_picker;

import 'package:flutter/material.dart';

import '../../i18n/i18n.dart';
import '../../services/image_search_services/unsplash/unsplash_image_search_result_item.dart';
import '../../utils/responsiveness/breakpoints.dart';
import '../../widgets/component/component.dart';
import '../../widgets/image_placeholder.dart';
import '../../widgets/image_search/image_search_result_tile.dart';
import '../../widgets/image_search/search_results.dart';
import '../../widgets/image_search/search_status.dart';
import '../home/component/utils/error_indicator.dart';
import 'unsplash_image_search_bloc.dart';
import 'unsplash_image_search_view_model.dart';

class UnsplashImageSearchDelegate<T extends UnsplashImageSearchResultItem?>
    extends SearchDelegate<T?> {
  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      key: const ValueKey('back-button'),
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: const Icon(Icons.clear_outlined),
        onPressed: () => query = '',
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
    required Widget Function(UnsplashImageImageSearchViewModel) builder,
  }) {
    return Component<UnsplashImageSearchBloc>(
      key: const ValueKey('ImageSearchComponent<UnsplashImageSearchResult>'),
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<UnsplashImageImageSearchViewModel>(
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

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);
}
