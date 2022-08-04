import 'package:flutter/material.dart';

import '../../../i18n/i18n.dart';
import '../../../widgets/stadium_text_field.dart';

class EmailField extends StatefulWidget {
  const EmailField(
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
  EmailFieldState createState() => EmailFieldState();
}

class EmailFieldState extends State<EmailField> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StadiumTextField(
      key: const ValueKey('email-field'),
      autofillHints: const [AutofillHints.email],
      controller: _textEditingController,
      placeholder: S.of(context).email,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      focusNode: widget._fieldFocus,
      onFieldSubmitted: (term) {
        widget._fieldFocus.unfocus();
        FocusScope.of(context).requestFocus(widget._nextFieldFocus);
      },
      errorText: widget.errorText,
      onChanged: widget.onChanged,
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }
}
