import 'dart:async';
import 'dart:math';

import 'package:injectable/injectable.dart';

import '../../../../data/models/confidence.dart';
import '../../../../data/repositories/review_session_repository.dart';
import '../../../../i18n/i18n.dart';
import '../../../../widgets/component/component_build_context.dart';
import 'congratulation_title_component.dart';
import 'congratulation_title_view_model.dart';

/// BLoC for the [CongratulationTitleComponent].
@injectable
class CongratulationTitleBloc with ComponentBuildContext {
  CongratulationTitleBloc(this._reviewSessionRepository);

  final ReviewSessionRepository _reviewSessionRepository;

  Stream<CongratulationTitleViewModel>? _viewModel;
  Stream<CongratulationTitleViewModel>? get viewModel => _viewModel;

  Stream<CongratulationTitleViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    String? title;

    return _viewModel = _reviewSessionRepository.session.map((reviewSession) {
      if (title != null) {
        return CongratulationTitleViewModel(title: title!);
      }

      final confidences = reviewSession.confidences;
      final knownCardsCount = confidences.values
          .where((c) => c.isNotEmpty && c.first == Confidence.known)
          .length;
      final unknownCardsCount = confidences.values
          .where((c) => c.isNotEmpty && c.first == Confidence.unknown)
          .length;
      title = _getTitle(knownCardsCount, unknownCardsCount);

      return CongratulationTitleViewModel(title: title!);
    });
  }

  String _getTitle(int knownCardsCount, int unknownCardsCount) {
    final neutralSayings = <String>[
      S.of(context).neutralSaying1,
      S.of(context).neutralSaying2,
      S.of(context).neutralSaying3,
      S.of(context).neutralSaying4,
    ];

    final positiveSayings = <String>[
      S.of(context).positiveSaying1,
      S.of(context).positiveSaying2,
      S.of(context).positiveSaying3,
      S.of(context).positiveSaying4,
      S.of(context).positiveSaying5,
      S.of(context).positiveSaying6,
      S.of(context).positiveSaying7,
      S.of(context).positiveSaying8,
      S.of(context).positiveSaying9,
      S.of(context).positiveSaying10,
      S.of(context).positiveSaying11,
      S.of(context).positiveSaying12,
      S.of(context).positiveSaying13,
      S.of(context).positiveSaying14,
      S.of(context).positiveSaying15,
      S.of(context).positiveSaying16,
    ];

    return knownCardsCount > unknownCardsCount
        ? positiveSayings[Random().nextInt(positiveSayings.length)]
        : neutralSayings[Random().nextInt(neutralSayings.length)];
  }
}
