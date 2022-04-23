import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AddressInput extends StatelessWidget {
  const AddressInput({
    Key? key,
    this.value,
  }) : super(key: key);

  final String? value;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.addressField,
      keyboardType: TextInputType.streetAddress,
      initialValue: value,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      minLines: 3,
      maxLines: 4,
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.pin_drop_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.address, allWords: true),
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
          fontWeight: FontWeight.w800,
        ),
      ),
      validator: FormBuilderValidators.compose(
        [
          FormBuilderValidators.maxLength(context, 255,
              errorText: Validations.eMaxLength.replaceAll("{len}", "255")),
        ],
      ),
    );
  }
}
