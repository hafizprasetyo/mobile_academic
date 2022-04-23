import 'package:basic_utils/basic_utils.dart';
import 'package:academic/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class PasswordInput extends StatelessWidget {
  const PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: Constants.passwordField,
      obscureText: true,
      style: TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: Icon(Icons.lock_outlined, size: 30),
        labelText: StringUtils.capitalize(Labels.password, allWords: true),
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
                  Validations.eRequired.replaceAll('{field}', Labels.password)),
          FormBuilderValidators.minLength(context, 4,
              errorText: Validations.eMinLength.replaceAll('{len}', '4')),
          FormBuilderValidators.maxLength(context, 64,
              errorText: Validations.eMaxLength.replaceAll('{len}', '64'))
        ],
      ),
    );
  }
}

// class RepeatPasswordInput extends StatelessWidget {
//   RepeatPasswordInput({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FormBuilderTextField(
//       name: 'repeatPassword',
//       obscureText: true,
//       style: TextStyle(
//         color: Theme.of(context).primaryColor,
//         fontWeight: FontWeight.bold,
//         fontSize: 16,
//       ),
//       decoration: InputDecoration(
//         border: InputBorder.none,
//         prefixIcon: Icon(Icons.loop_outlined, size: 30),
//         labelText:
//             StringUtils.capitalize(Labels.repeat_password, allWords: true),
//         labelStyle: TextStyle(
//           fontSize: 18,
//           color: Colors.grey[400],
//           fontWeight: FontWeight.w800,
//         ),
//       ),
//     );
//   }
// }
