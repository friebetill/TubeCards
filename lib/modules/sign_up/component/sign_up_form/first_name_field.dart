import 'package:flutter/material.dart';

import '../../../../i18n/i18n.dart';
import '../../../../widgets/stadium_text_field.dart';

class FirstNameField extends StatefulWidget {
  const FirstNameField(
    this.onChanged,
    this.errorText,
    this._fieldFocus,
    this._nextFieldFocus, {
    Key? key,
  }) : super(key: key);

  final String? errorText;
  final ValueChanged<String> onChanged;
  final FocusNode _fieldFocus;
  final FocusNode _nextFieldFocus;

  @override
  FirstNameFieldState createState() => FirstNameFieldState();
}

class FirstNameFieldState extends State<FirstNameField> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StadiumTextField(
        placeholder: S.of(context).firstName,
        errorText: widget.errorText,
        controller: _textEditingController,
        onChanged: widget.onChanged,
        textInputAction: TextInputAction.next,
        focusNode: widget._fieldFocus,
        textCapitalization: TextCapitalization.words,
        onFieldSubmitted: (term) {
          widget._fieldFocus.unfocus();
          FocusScope.of(context).requestFocus(widget._nextFieldFocus);
        },
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
