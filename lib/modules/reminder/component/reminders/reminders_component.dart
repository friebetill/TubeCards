import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../utils/tooltip_message.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/page_callback_shortcuts.dart';
import '../../../reminder_add/reminder_add_page.dart';
import '../reminder_tile/reminder_tile_component.dart';
import 'reminders_bloc.dart';
import 'reminders_view_model.dart';

class RemindersComponent extends StatelessWidget {
  const RemindersComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<RemindersBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<RemindersViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            return _RemindersView(viewModel: snapshot.data);
          },
        );
      },
    );
  }
}

@immutable
class _RemindersView extends StatefulWidget {
  const _RemindersView({required this.viewModel, Key? key}) : super(key: key);

  final RemindersViewModel? viewModel;

  @override
  _RemindersViewState createState() => _RemindersViewState();
}

class _RemindersViewState extends State<_RemindersView> {
  double _appBarElevation = 0;

  @override
  Widget build(BuildContext context) {
    return PageCallbackShortcuts(
      child: Scaffold(
        appBar: _buildAppBar(),
        body: widget.viewModel != null
            ? widget.viewModel!.reminders.isEmpty
                ? _buildEmptyRemindersScreen()
                : _buildReminderList()
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add_outlined),
          label: Text(S.of(context).addReminder.toUpperCase()),
          onPressed: () => CustomNavigator.getInstance()
              .pushNamed(ReminderAddPage.routeName),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(S.of(context).reminder),
      leading: IconButton(
        icon: const BackButtonIcon(),
        onPressed: CustomNavigator.getInstance().pop,
        tooltip: backTooltip(context),
      ),
      elevation: _appBarElevation,
    );
  }

  Widget _buildEmptyRemindersScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Icon(
          Icons.notifications_none,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white24
              : Colors.grey.shade300,
          size: 128,
        ),
        const SizedBox(height: 16),
        Text(
          S.of(context).reminderAppearHere,
          style: TextStyle(color: Theme.of(context).hintColor),
          textAlign: TextAlign.center,
        ),
        // Add padding to center the image between the app bar
        // and the floating action button (56px + 16px padding).
        const SizedBox(height: 56.0 + 16),
      ],
    );
  }

  Widget _buildReminderList() {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.separated(
        separatorBuilder: (context, index) => const Divider(height: 1),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: widget.viewModel!.reminders.length,
        itemBuilder: (context, index) => ReminderTileComponent(
          key: ValueKey(widget.viewModel!.reminders[index].id),
          reminderId: widget.viewModel!.reminders[index].id,
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final elevation = notification.metrics.extentBefore <= 0 ? 0.0 : 4.0;
    if (elevation != _appBarElevation) {
      setState(() => _appBarElevation = elevation);
    }

    return false;
  }
}
