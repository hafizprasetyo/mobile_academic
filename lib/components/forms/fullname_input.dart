import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class FullNameInput extends StatelessWidget {
  const FullNameInput({
    Key? key,
    this.value,
  }) : super(key: key);

  final String? value;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.fullnameField,
      keyboardType: TextInputType.name,
      initialValue: value,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.person_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.full_name, allWords: true),
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.required(context,
              errorText: Validations.eRequired
                  .replaceAll('{field}', Labels.full_name)),
          FormBuilderValidators.match(context, Validations.alphaNumSpace,
              errorText: Validations.eAlphaNumSpace)
        ],
      ),
    );
  }
}
