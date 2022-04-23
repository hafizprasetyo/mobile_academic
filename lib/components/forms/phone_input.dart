import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class PhoneInput extends StatelessWidget {
  const PhoneInput({
    Key? key,
    this.value,
  }) : super(key: key);

  final String? value;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.phoneField,
      keyboardType: TextInputType.phone,
      initialValue: value,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.phone_enabled_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.phone_number, allWords: true),
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.maxLength(context, 25,
              errorText: Validations.eMaxLength.replaceAll("{len}", "25")),
          FormBuilderValidators.numeric(context,
              errorText: Validations.eNumeric),
        ],
      ),
    );
  }
}
