import 'package:built_collection/built_collection.dart';
import 'package:flutter/foundation.dart';

import 'average_learning_state.dart';
import 'card.dart';
import 'confidence.dart';

class ReviewSession {
  ReviewSession({
    required this.title,
    required this.card,
    required this.progress,
    required this.isFrontSide,
    required this.hasNextCard,
    required this.confidences,
    required this.addRepetition,
    required this.setIsFrontSide,
    required this.initialLearningState,
    required this.loadLearningState,
  });

  final String title;
  final Card? card;
  final double progress;
  final bool isFrontSide;
  final bool hasNextCard;
  final BuiltMap<String, List<Confidence>> confidences;
  final AverageLearningState? initialLearningState;

  final Future<void> Function(Confidence) addRepetition;
  final ValueChanged<bool> setIsFrontSide;
  final AsyncValueGetter<AverageLearningState>? loadLearningState;
}
