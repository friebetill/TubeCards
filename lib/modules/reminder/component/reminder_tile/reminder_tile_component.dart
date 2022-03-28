import 'package:flutter/material.dart';

import '../../../../data/models/reminder.dart';
import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component.dart';
import '../../weekday.dart';
import 'expand_animation.dart';
import 'reminder_tile_bloc.dart';
import 'reminder_tile_view_model.dart';

/// A custom widget based on [ExpansionTile] showing information about the given
/// [Reminder] that expands and collapses the tile to reveal or hide
/// settings for the [Reminder].
class ReminderTileComponent extends StatelessWidget {
  const ReminderTileComponent({required this.reminderId, Key? key})
      : super(key: key);

  /// The ID of the reminder, which is represented by these tiles
  final int reminderId;

  @override
  Widget build(BuildContext context) {
    return Component<ReminderTileBloc>(
      createViewModel: (bloc) => bloc.createViewModel(reminderId),
      builder: (context, bloc) {
        return StreamBuilder<ReminderTileViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _ReminderTileView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

@immutable
class _ReminderTileView extends StatefulWidget {
  const _ReminderTileView({required this.viewModel, Key? key})
      : super(key: key);

  final ReminderTileViewModel viewModel;

  @override
  _ReminderTileViewState createState() => _ReminderTileViewState();
}

class _ReminderTileViewState extends State<_ReminderTileView>
    with SingleTickerProviderStateMixin {
  late ExpandAnimation _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandAnimation = ExpandAnimation(AnimationController(vsync: this));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _expandAnimation.isExpanded
          ? _expandAnimation.shrink()
          : _expandAnimation.expand(),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitle(),
            _expandAnimation.buildExpansionAnimation(
              child: _buildExpansionContent(),
            ),
            const SizedBox(height: 8),
            _buildSubtitle(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _expandAnimation.dispose();
    super.dispose();
  }

  Widget _buildTitle() {
    final text = widget.viewModel.reminder.time;
    final textColor = widget.viewModel.reminder.enabled!
        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
        : Theme.of(context).textTheme.caption!.color;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: widget.viewModel.onWeeklyTimeEdit,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
          ),
          child: AnimatedDefaultTextStyle(
            style: Theme.of(context).textTheme.subtitle1!.merge(
                  TextStyle(color: textColor, fontSize: 36),
                ),
            duration: const Duration(milliseconds: 200),
            child: Text(text),
          ),
        ),
        Switch(
          value: widget.viewModel.reminder.enabled!,
          onChanged: widget.viewModel.onToggleReminder,
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return AnimatedBuilder(
      animation: _expandAnimation.view,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_expandAnimation.isExpanded)
              TextButton.icon(
                label: Text(
                  S.of(context).delete.toUpperCase(),
                  style: TextStyle(color: Theme.of(context).iconTheme.color),
                ),
                icon: Icon(
                  Icons.delete,
                  color: Theme.of(context).iconTheme.color,
                ),
                onPressed: widget.viewModel.deleteReminder,
              ),
            if (!_expandAnimation.isExpanded)
              Text(
                _buildAbbreviatedWeekdays(),
                style: TextStyle(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            RotationTransition(
              turns: _expandAnimation.iconTurns,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.expand_more_outlined),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpansionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _buildWeekAvatars(),
        ),
      ],
    );
  }

  List<Widget> _buildWeekAvatars() {
    return widget.viewModel.reminder.weekdayStatus.entries
        .map((kv) => _buildWeekdayAvatar(kv.key))
        .toList();
  }

  Widget _buildWeekdayAvatar(Weekday weekday) {
    final isEnabled = widget.viewModel.reminder.weekdayStatus[weekday]!;
    final timeOfDay = widget.viewModel.reminder.timeOfDay;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode && isEnabled || !isDarkMode && !isEnabled
        ? Colors.black
        : Colors.white;
    final disabledBackgroundColor =
        isDarkMode ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20);
    final enabledBackgroundColor = widget.viewModel.reminder.enabled!
        ? Theme.of(context).colorScheme.primary.withOpacity(0.8)
        : Theme.of(context).disabledColor;

    return GestureDetector(
      onTap: () => widget.viewModel.toggleWeekday(weekday),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          color: isEnabled ? enabledBackgroundColor : disabledBackgroundColor,
        ),
        key: Key('$timeOfDay-$weekday'),
        child: Text(
          weekday.toChar(context),
          style: TextStyle(fontSize: 16, color: textColor),
        ),
      ),
    );
  }

  String _buildAbbreviatedWeekdays() {
    final enabledCount = widget.viewModel.reminder.weekdayStatus.values
        .map((v) => v ? 1 : 0)
        .reduce((a, b) => a + b);
    if (enabledCount == 7) {
      return S.of(context).everyDay;
    } else if (enabledCount == 0) {
      return S.of(context).noDaysSelected;
    }

    return widget.viewModel.reminder.weekdayStatus.entries
        .where((kv) => kv.value)
        .map((kv) => kv.key.abbreviation(context))
        .join(', ');
  }
}
