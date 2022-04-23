import 'package:academic/utils/app_theme.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EmailInput extends StatelessWidget {
  const EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.emailField,
      keyboardType: TextInputType.emailAddress,
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
        prefixIcon: Icon(Icons.mail_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.email, allWords: true),
        labelStyle: TextStyle(
          fontSize: 16,
          color: AppTheme.deactivatedText,
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(context,
              errorText:
                  Validations.eRequired.replaceAll('{field}', Labels.email)),
          FormBuilderValidators.email(context, errorText: Validations.eEmail),
          FormBuilderValidators.maxLength(context, 128,
              errorText: Validations.eMaxLength.replaceAll('{len}', '128'))
        ],
      ),
    );
  }
}
