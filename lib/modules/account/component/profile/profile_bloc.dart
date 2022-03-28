import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../data/repositories/user_repository.dart';
import 'profile_component.dart';
import 'profile_view_model.dart';

/// BLoC for the [ProfileComponent].
///
/// Exposes a [ProfileViewModel] for that component to use.
@injectable
class ProfileBloc {
  ProfileBloc(this._userRepository);

  final UserRepository _userRepository;

  Stream<ProfileViewModel>? _viewModel;
  Stream<ProfileViewModel>? get viewModel => _viewModel;

  Stream<ProfileViewModel> createViewModel() {
    if (_viewModel != null) {
      return _viewModel!;
    }

    return _viewModel =
        _userRepository.viewer().map((user) => ProfileViewModel(user: user!));
  }
}
