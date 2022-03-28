import 'package:flutter/material.dart' hide Card;

import '../../../../i18n/i18n.dart';
import '../../../../utils/durations.dart';
import '../../../../utils/themes/custom_theme.dart';
import '../../../../widgets/animated_number.dart';
import '../../../../widgets/component/component.dart';
import '../../../../widgets/labeled_bar.dart';
import '../congratulation_title/congratulation_title_component.dart';
import 'review_statistic_bloc.dart';
import 'review_statistic_view_model.dart';

class ReviewStatisticComponent extends StatelessWidget {
  const ReviewStatisticComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<ReviewStatisticBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<ReviewStatisticViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _LearnStatisticView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

class _LearnStatisticView extends StatelessWidget {
  const _LearnStatisticView({required this.viewModel, Key? key})
      : super(key: key);

  final ReviewStatisticViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        children: <Widget>[
          if (viewModel.showIncreaseStatistic) _buildIncreaseStatistic(context),
          if (!viewModel.showIncreaseStatistic)
            const CongratulationTitleComponent(),
          if (!viewModel.showIncreaseStatistic) const SizedBox(height: 8),
          if (!viewModel.showIncreaseStatistic)
            Text(
              S.of(context).practiceSessionsAreNotSaved,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.white),
            ),
          const SizedBox(height: 32),
          _buildKnownCardsBar(context),
          const SizedBox(height: 16),
          _buildUnknownCardsBar(context),
        ],
      ),
    );
  }

  Widget _buildIncreaseStatistic(BuildContext context) {
    final numberStyle =
        Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white);
    final unitStyle =
        Theme.of(context).textTheme.headline5!.copyWith(color: Colors.white);
    final subtitleStyle =
        Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.white);

    final strengthIncrease = viewModel.strengthIncrease != null
        ? viewModel.strengthIncrease! * 100
        : 0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: strengthIncrease >= 0 ? '+' : '-',
                    style: unitStyle,
                  ),
                  WidgetSpan(
                    style: numberStyle,
                    child: SizedBox(
                      // Set the width to the minimum width of the number so
                      // that the text does not jump during the animation.
                      width: _getNumberWidth(strengthIncrease.abs()),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedNumber(
                          end: strengthIncrease.abs(),
                          duration: Durations.milliseconds2000,
                          style: numberStyle,
                          decimalPoint: 0,
                          isLoading: viewModel.isLoading,
                          loadingPlaceHolder: '0',
                        ),
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '%',
                    style: unitStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(S.of(context).memorized, style: subtitleStyle),
          ],
        ),
      ],
    );
  }

  double _getNumberWidth(double number) {
    return number < 10
        ? 24.0
        : number < 100
            ? 44.0
            : 64.0;
  }

  Widget _buildKnownCardsBar(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return LabeledBar(
      foregroundColor: isLightTheme
          ? const Color(0xFF00FF6A)
          : Theme.of(context).custom.successColor,
      backgroundColor: const Color(0x11FFFFFF),
      fillPercentage: viewModel.knownCardsCount /
          (viewModel.knownCardsCount + viewModel.unknownCardsCount),
      leftText: Text(
        S.of(context).correct,
        style: _smallTextStyle(context),
      ),
      rightText: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: viewModel.knownCardsCount.toString(),
              style: _largeTextStyle(context),
            ),
            TextSpan(text: ' ', style: _smallTextStyle(context)),
            TextSpan(
              text:
                  S.of(context).cards(viewModel.knownCardsCount).toLowerCase(),
              style: _smallTextStyle(context),
            ),
          ],
        ),
      ),
      animationDuration: Duration.zero,
    );
  }

  Widget _buildUnknownCardsBar(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;

    return LabeledBar(
      foregroundColor:
          isLightTheme ? const Color(0xFF00D4FF) : const Color(0xFF66AAB8),
      backgroundColor: const Color(0x11ffffff),
      fillPercentage: viewModel.unknownCardsCount /
          (viewModel.knownCardsCount + viewModel.unknownCardsCount),
      leftText: Text(
        S.of(context).incorrect,
        style: _smallTextStyle(context),
      ),
      rightText: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: viewModel.unknownCardsCount.toString(),
              style: _largeTextStyle(context),
            ),
            TextSpan(text: ' ', style: _smallTextStyle(context)),
            TextSpan(
              text: S
                  .of(context)
                  .cards(viewModel.unknownCardsCount)
                  .toLowerCase(),
              style: _smallTextStyle(context),
            ),
          ],
        ),
      ),
      animationDuration: Duration.zero,
    );
  }

  TextStyle _smallTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.subtitle2!.copyWith(color: Colors.white);
  }

  TextStyle _largeTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.subtitle1!.copyWith(color: Colors.white);
  }
}
