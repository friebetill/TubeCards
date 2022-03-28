import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../widgets/component/component_build_context.dart';
import '../../component/component_life_cycle_listener.dart';
import 'analyze_file_component.dart';
import 'analyze_file_view_model.dart';

/// BLoC for the [AnalyzeFileComponent].
@injectable
class AnalyzeFileBloc with ComponentBuildContext, ComponentLifecycleListener {
  Stream<AnalyzeFileViewModel>? _viewModel;
  Stream<AnalyzeFileViewModel>? get viewModel => _viewModel;

  final _errorText = BehaviorSubject<String?>.seeded(null);
  final _onOpenEmailAppTap = BehaviorSubject<AsyncCallback?>.seeded(null);

  Stream<AnalyzeFileViewModel> createViewModel(
    AnalyzeFileErrorCallback analyzeFile,
  ) {
    if (_viewModel != null) {
      return _viewModel!;
    }

    analyzeFile((errorText, [handleOpenEmailAppTap]) {
      _errorText.add(errorText);
      _onOpenEmailAppTap.add(handleOpenEmailAppTap);
    });

    return _viewModel = Rx.combineLatest2(
      _errorText,
      _onOpenEmailAppTap,
      _createViewModel,
    );
  }

  AnalyzeFileViewModel _createViewModel(
    String? errorText,
    AsyncCallback? handleOpenEmailAppTap,
  ) {
    return AnalyzeFileViewModel(
      errorText: errorText,
      onOpenEmailAppTap: handleOpenEmailAppTap,
    );
  }

  @override
  void dispose() {
    _errorText.close();
    _onOpenEmailAppTap.close();
    super.dispose();
  }
}
