import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class EssayInput extends StatelessWidget {
  const EssayInput({
    Key? key,
    this.value,
    this.name,
  }) : super(key: key);

  final String? value;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: name ?? Constants.essayField,
      keyboardType: TextInputType.multiline,
      initialValue: value,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      minLines: 1,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: "Ketik jawaban kamu disini...",
        hintStyle: TextStyle(
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
