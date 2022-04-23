import 'package:academic/utils/app_theme.dart';
import 'package:academic/utils/constants.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class UnameInput extends StatelessWidget {
  const UnameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.unameField,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(
            width: 2.0,
            color: AppTheme.primaryColor,
          ),
        ),
        prefixIcon: Icon(Icons.person_outline_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.uname, allWords: true),
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.deactivatedText,
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(
            context,
            errorText:
                Validations.eRequired.replaceAll('{field}', Labels.uname),
          ),
        ],
      ),
    );
  }
}
