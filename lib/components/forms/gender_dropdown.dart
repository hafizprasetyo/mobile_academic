import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    Key? key,
    this.value,
  }) : super(key: key);

  final String? value;

  @override
  Widget build(BuildContext context) {
    return FormBuilderDropdown<String?>(
      name: Constants.genderField,
      initialValue: value,
      focusColor: Colors.transparent,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.badge_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.gender, allWords: true),
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          fontWeight: FontWeight.w800,
        ),
      ),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(''),
        ),
        DropdownMenuItem(
          value: "male",
          child: Text('Laki-laki'),
        ),
        DropdownMenuItem(
          value: "female",
          child: Text('Perempuan'),
        ),
      ],
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.maxLength(
            context,
            255,
            errorText: Validations.eMaxLength.replaceAll("{len}", "255"),
          ),
        ],
      ),
    );
  }
}
