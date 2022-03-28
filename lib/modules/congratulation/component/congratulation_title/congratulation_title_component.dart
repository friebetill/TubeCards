import 'package:flutter/material.dart' hide Card;

import '../../../../widgets/component/component.dart';
import 'congratulation_title_bloc.dart';
import 'congratulation_title_view_model.dart';

class CongratulationTitleComponent extends StatelessWidget {
  const CongratulationTitleComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Component<CongratulationTitleBloc>(
      createViewModel: (bloc) => bloc.createViewModel(),
      builder: (context, bloc) {
        return StreamBuilder<CongratulationTitleViewModel>(
          stream: bloc.viewModel,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return _CongratulationTitleView(viewModel: snapshot.data!);
          },
        );
      },
    );
  }
}

class _CongratulationTitleView extends StatelessWidget {
  const _CongratulationTitleView({required this.viewModel, Key? key})
      : super(key: key);

  final CongratulationTitleViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Text(
      viewModel.title,
      style:
          Theme.of(context).textTheme.headline4!.copyWith(color: Colors.white),
    );
  }
}
