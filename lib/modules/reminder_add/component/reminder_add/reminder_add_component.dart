import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../utils/custom_navigator.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/list_tile_adapter.dart';
import 'reminder_add_bloc.dart';
import 'reminder_add_view_model.dart';

class ReminderAddComponent extends StatelessWidget {
  const ReminderAddComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ReminderAddBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ReminderAddViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _ReminderAddView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ReminderAddView extends StatelessWidget {
  const _ReminderAddView({required this.viewModel, Key? key}) : super(key: key);

  final ReminderAddViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: ListView(
        children: <Widget>[
          _buildTimeOfDayTile(context),
          _buildDaysOfTheWeekTile(context),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(S.of(context).addReminder),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_outlined),
        onPressed: CustomNavigator.getInstance().pop,
        tooltip: S.of(context).close,
      ),
      actions: <Widget>[
        IconButton(
          key: const ValueKey('done-button'),
          icon: Icon(
            Icons.check_outlined,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: viewModel.handleDone,
          tooltip: S.of(context).addReminder,
        ),
      ],
    );
  }

  Widget _animatedSubheadStyle(Widget child, BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .subtitle1!
          .merge(TextStyle(color: ListTileTheme.of(context).selectedColor)),
      duration: const Duration(milliseconds: 100),
      child: child,
    );
  }

  Widget _animatedBodyStyle(Widget child, BuildContext context) {
    return AnimatedDefaultTextStyle(
      style: Theme.of(context)
          .textTheme
          .bodyText2!
          .merge(TextStyle(color: Theme.of(context).textTheme.caption!.color)),
      duration: const Duration(milliseconds: 100),
      child: child,
    );
  }

  Widget _buildTimeOfDayTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: _animatedSubheadStyle(
          Text(S.of(context).reminderTime),
          context,
        ),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: _animatedSubheadStyle(
            Text(
              viewModel.reminder.timeOfDay.toReadableString(),
              style: const TextStyle(fontSize: 24),
            ),
            context,
          ),
        ),
        onTap: viewModel.handleEditTime,
      ),
    );
  }

  Widget _buildDaysOfTheWeekTile(BuildContext context) {
    return ListTileAdapter(
      child: ListTile(
        title: _animatedSubheadStyle(Text(S.of(context).weekdays), context),
        subtitle: _animatedBodyStyle(
          Text(_buildAbbreviatedWeekdays(context)),
          context,
        ),
        onTap: viewModel.handleEditWeekdays,
      ),
    );
  }

  String _buildAbbreviatedWeekdays(BuildContext context) {
    final enabledCount = viewModel.reminder.weekdayStatus.values
        .map((v) => v ? 1 : 0)
        .reduce((a, b) => a + b);
    if (enabledCount == 7) {
      return S.of(context).everyDay;
    } else if (enabledCount == 0) {
      return S.of(context).noDaysSelected;
    }

    return viewModel.reminder.weekdayStatus.entries
        .where((kv) => kv.value)
        .map((kv) => kv.key.abbreviation(context))
        .join(', ');
  }
}
