import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class UsernameInput extends StatelessWidget {
  const UsernameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.usernameField,
      keyboardType: TextInputType.name,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(
          Icons.alternate_email_outlined,
          size: 30,
        ),
        labelText: StringUtils.capitalize(Labels.username, allWords: true),
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(context,
              errorText:
                  Validations.eRequired.replaceAll('{field}', Labels.username)),
          FormBuilderValidators.match(context, Validations.alphaDash,
              errorText: Validations.eAlphaDash),
          FormBuilderValidators.minLength(context, 3,
              errorText: Validations.eMinLength.replaceAll('{len}', '3')),
          FormBuilderValidators.maxLength(context, 16,
              errorText: Validations.eMaxLength.replaceAll('{len}', '16'))
        ],
      ),
    );
  }
}
