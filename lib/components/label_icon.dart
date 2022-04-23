import 'package:flutter/material.dart';
import 'package:academic/utils/app_theme.dart';

class LabelIcon extends StatelessWidget {
  const LabelIcon({
    Key? key,
    required this.label,
    required this.icon,
    this.iconSize,
    this.iconColor,
    this.color,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final double? iconSize;
  final Color? iconColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: iconSize ?? 21,
          color: iconColor ?? color ?? AppTheme.deactivatedText,
        ),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            softWrap: true,
            style: TextStyle(
              color: color ?? AppTheme.deactivatedText,
            ),
          ),
        )
      ],
    );
  }
}
