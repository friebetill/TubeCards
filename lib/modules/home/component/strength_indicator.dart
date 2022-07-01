import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../../../i18n/i18n.dart';

class StrengthIndicator extends StatelessWidget {
  const StrengthIndicator({
    required this.strength,
    this.numberStyle,
    this.unitStyle,
    this.showSubtitle = true,
    Key? key,
  }) : super(key: key);

  final double strength;
  final bool showSubtitle;
  final TextStyle? numberStyle;
  final TextStyle? unitStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CircularPercentIndicator(
          radius: constraints.maxHeight / 2,
          lineWidth: constraints.maxHeight / 18,
          percent: strength,
          backgroundColor: _backgroundColor(context),
          progressColor: _foregroundColor(context),
          circularStrokeCap: CircularStrokeCap.round,
          center: Padding(
            padding: EdgeInsets.all(constraints.maxHeight / 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPercentage(context),
                if (showSubtitle) _buildSubtitle(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPercentage(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // Add space to center the strength number
          Text(
            '  ',
            style: unitStyle ?? Theme.of(context).textTheme.headline6!,
          ),
          Text(
            (strength * 100).toStringAsFixed(0),
            style: numberStyle ?? Theme.of(context).textTheme.headline4!,
          ),
          Text('%', style: unitStyle ?? Theme.of(context).textTheme.headline6!),
        ],
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          S.of(context).memorized,
          style: Theme.of(context).textTheme.bodyText2!,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Color _foregroundColor(BuildContext context) {
    if (strength < 0.25) {
      return Theme.of(context).colorScheme.error;
    } else if (strength < 0.75) {
      return Theme.of(context).brightness == Brightness.light
          ? const Color(0xFFFFDB5C)
          : Colors.yellowAccent.shade100;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _backgroundColor(BuildContext context) {
    final lightModeEnabled = Theme.of(context).brightness == Brightness.light;
    const darkModeBlendColor = Color(0xbb2f2f2f);

    if (strength < 0.25) {
      return lightModeEnabled
          ? const Color(0xFFFFEAE9)
          : Color.alphaBlend(darkModeBlendColor, Colors.red.shade900);
    } else if (strength < 0.75) {
      return lightModeEnabled
          ? Colors.yellow.shade100
          : Color.alphaBlend(darkModeBlendColor, Colors.yellow.shade900);
    } else {
      return Theme.of(context).selectedRowColor;
    }
  }
}
