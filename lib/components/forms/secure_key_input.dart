import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class SecureKeyInput extends StatelessWidget {
  const SecureKeyInput({Key? key, required this.originalKey}) : super(key: key);

  final String originalKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: FormBuilderTextField(
        name: Constants.secureKeyField,
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(Icons.vpn_key_outlined, size: 30),
          ),
          labelText: StringUtils.capitalize(Labels.secure_key, allWords: true),
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
                    .replaceAll('{field}', Labels.secure_key)),
            FormBuilderValidators.equal(context, this.originalKey,
                errorText: Validations.eEqual.replaceAll(
                    '{field}', StringUtils.capitalize(Labels.secure_key))),
          ],
        ),
      ),
    );
  }
}
