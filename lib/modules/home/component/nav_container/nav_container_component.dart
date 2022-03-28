import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/logging/visual_element_ids.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/visual_element.dart';
import '../../../marketplace/component/marketplace/marketplace_component.dart';
import '../bottom_navigation_button.dart';
import '../home/home_component.dart';
import '../home_app_bar.dart';
import '../marketplace_app_bar.dart';
import '../utils/home_skeleton.dart';
import 'nav_container_bloc.dart';
import 'nav_container_view_model.dart';

/// The navigation bar for the main control of the app screens.
class NavContainerComponent extends StatelessWidget {
  const NavContainerComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<NavContainerBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<NavContainerViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const HomeSkeleton();
            }

            return _NavContainerView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

class _NavContainerView extends StatefulWidget {
  const _NavContainerView({required this.viewModel, Key? key})
      : super(key: key);

  final NavContainerViewModel viewModel;

  @override
  _NavContainerViewState createState() => _NavContainerViewState();
}

class _NavContainerViewState extends State<_NavContainerView>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  // It's forbidden to access _pageController.page before first build
  // that's why we need to have this variable, https://bit.ly/33mxxME.
  int currentIndex = 0;

  // The name "Speed dial" comes from Material, https://bit.ly/2ThxHTr.
  late AnimationController _speedDialController;
  bool _isSpeedDialShown = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        if (_pageController.page!.round() != currentIndex) {
          setState(() => currentIndex = _pageController.page!.round());
        }
      });
    _speedDialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addStatusListener(
        (status) => setState(
          () => _isSpeedDialShown = status != AnimationStatus.dismissed,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isSpeedDialShown ? _speedDialController.reverse : null,
      child: Scaffold(
        extendBody: true,
        appBar: _buildAppBar(),
        floatingActionButton:
            currentIndex == 0 ? _buildFloatingActionButtons() : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildNavBar(),
        body: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            AbsorbPointer(
              absorbing: _isSpeedDialShown,
              child: const HomeComponent(),
            ),
            const MarketplaceComponent(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _speedDialController.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return (currentIndex == 0
        ? HomeAppBar(
            ignoreClicks: _isSpeedDialShown,
            userAvatar: _buildUserAvatar(context),
            onRefreshTap: widget.viewModel.onRefreshTap,
            isRefreshLoading: widget.viewModel.isLoading,
          )
        : MarketplaceAppBar(
            userAvatar: _buildUserAvatar(context),
            onSearchTap: widget.viewModel.onSearchOfferTap,
          )) as PreferredSizeWidget;
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Tooltip(
      message: S.of(context).account,
      child: VisualElement(
        id: VEs.accountButton,
        childBuilder: (controller) {
          return IconButton(
            iconSize: 32,
            key: const ValueKey('account-button'),
            onPressed: () {
              controller.logTap();
              widget.viewModel.onAccountTap();
            },
            icon: widget.viewModel.user.isAnonymous!
                ? const Icon(Icons.account_circle_outlined)
                : Hero(
                    tag: 'account-avatar',
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      child: Text(
                        widget.viewModel.user.firstName![0].toUpperCase(),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomAppBar(
      elevation: 8,
      child: SizedBox(
        height: 56,
        child: AbsorbPointer(
          absorbing: _isSpeedDialShown,
          child: Row(
            children: <Widget>[
              const SizedBox(width: 24),
              VisualElement(
                id: VEs.homeButton,
                childBuilder: (controller) {
                  return BottomNavigationButton(
                    icon: Icons.home_outlined,
                    isSelected: currentIndex == 0,
                    label: S.of(context).home,
                    onTap: () {
                      controller.logTap();
                      _pageController.jumpToPage(/*index=*/ 0);
                    },
                  );
                },
              ),
              const SizedBox(width: 32),
              VisualElement(
                id: VEs.storeButton,
                childBuilder: (controller) {
                  return BottomNavigationButton(
                    icon: Icons.store_outlined,
                    isSelected: currentIndex == 1,
                    label: S.of(context).store,
                    onTap: () {
                      controller.logTap();
                      _pageController.jumpToPage(/*index=*/ 1);
                    },
                  );
                },
              ),
              const Spacer(),
              if (currentIndex == 0)
                VisualElement(
                    id: VEs.searchButton,
                    childBuilder: (controller) {
                      return IconButton(
                        icon: const Icon(Icons.search_outlined),
                        onPressed: () {
                          controller.logTap();
                          widget.viewModel.onSearchTap();
                        },
                        tooltip: S.of(context).search,
                      );
                    }),
              if (currentIndex == 0) const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Don't generate invisible buttons because it changes the positions
        // of the snackbar.
        if (!_speedDialController.isDismissed) _buildImportButton(),
        if (!_speedDialController.isDismissed) _buildJoinDeckButton(),
        _buildAddDeckButton(),
        // Normally the center of the FAB widget is positioned on the center
        // of the FAB position. But since the column is large and therefore
        // goes over the edge of the screen, Flutter moves the column up
        // until the widget is completely visible. Now in order for the
        // AddDeckButton to be positioned in the center of the FAB position,
        // a SizedBox with a height of 28 is added.
        if (!_speedDialController.isDismissed) const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildAddDeckButton() {
    return VisualElement(
      id: VEs.addDeckButton,
      childBuilder: (controller) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onSecondaryTap: () {
              controller.logSecondaryTap();
              _onSpeedDialTap();
            },
            onLongPress: () {
              controller.logLongPress();
              _onSpeedDialTap();
            },
            child: FloatingActionButton(
              onPressed: () {
                if (!_isSpeedDialShown) {
                  controller.logTap();
                  widget.viewModel.onAddDeckTap();
                }
                _speedDialController.reverse();
              },
              child: AnimatedBuilder(
                animation: _speedDialController,
                builder: (_, child) {
                  return Transform(
                    transform: Matrix4.rotationZ(
                      _speedDialController.value * math.pi * 0.75,
                    ),
                    alignment: FractionalOffset.center,
                    child: child,
                  );
                },
                child: const Icon(Icons.add_outlined),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImportButton() {
    return VisualElement(
      id: VEs.importButton,
      childBuilder: (controller) {
        return _buildSpeedDialButton(
          position: 0,
          onTap: () {
            controller.logTap();
            widget.viewModel.onImportTap();
          },
          label: S.of(context).import.toUpperCase(),
        );
      },
    );
  }

  Widget _buildJoinDeckButton() {
    return VisualElement(
      id: VEs.joinDeckButton,
      childBuilder: (controller) {
        return _buildSpeedDialButton(
          position: 1,
          onTap: () {
            controller.logTap();
            widget.viewModel.onJoinDeckTap();
          },
          label: S.of(context).joinDeck.toUpperCase(),
        );
      },
    );
  }

  Widget _buildSpeedDialButton({
    required int position,
    required String label,
    required VoidCallback onTap,
  }) {
    const speedDialMenuItemCount = 2;

    return Container(
      height: 70,
      alignment: Alignment.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _speedDialController,
          curve: Interval(
            0,
            // Necessary for the FABs to pop up one after the other.
            1.0 - position / speedDialMenuItemCount / 2.0,
            curve: Curves.easeOut,
          ),
        ),
        child: FloatingActionButton.extended(
          heroTag: null,
          backgroundColor: Theme.of(context).colorScheme.background,
          onPressed: () {
            onTap();
            _speedDialController.reverse();
          },
          label: Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),
    );
  }

  void _onSpeedDialTap() {
    _isSpeedDialShown
        ? _speedDialController.reverse()
        : _speedDialController.forward();
  }
}
