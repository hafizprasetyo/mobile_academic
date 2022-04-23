import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFF4F4F4);
  static const Color mainBtn = Color(0xff132137);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color darkGrey = Color(0xFF313A44);
  static const Color disabled = Color(0xFFC0C0C0);
  static const Color primary = Color(0xff132137);

  static const Color normalText = Color(0xFF2F2F2F);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF969696);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'WorkSans';

  static const primaryColor = Color(0xFF30384D);
  static const secondaryColor = Color(0xFF4A6572);
  static const kBgLightColor = Color(0xFFF2F4FC);
  static const kBgDarkColor = Color(0xFFEBEDFA);
  static const kBadgeColor = Color(0xFFEE376E);
  static const kGrayColor = Color(0xFF8793B2);
  static const kTitleTextColor = Color(0xFF30384D);
  static const kTextColor = Color(0xFF4D5875);

  static const kDefaultPadding = 20.0;

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText2: body2,
    bodyText1: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static TextTheme _buildTextTheme(TextTheme base) {
    const String fontName = 'WorkSans';
    return base
        .copyWith(
          headline1: base.headline1?.copyWith(fontFamily: fontName),
          headline2: base.headline2?.copyWith(fontFamily: fontName),
          headline3: base.headline3?.copyWith(fontFamily: fontName),
          headline4: base.headline4?.copyWith(fontFamily: fontName),
          headline5: base.headline5?.copyWith(fontFamily: fontName),
          headline6: base.headline6?.copyWith(fontFamily: fontName),
          button: base.button?.copyWith(fontFamily: fontName),
          caption: base.caption?.copyWith(fontFamily: fontName),
          bodyText1: base.bodyText1?.copyWith(fontFamily: fontName),
          bodyText2: base.bodyText2?.copyWith(fontFamily: fontName),
          subtitle1: base.subtitle1?.copyWith(fontFamily: fontName),
          subtitle2: base.subtitle2?.copyWith(fontFamily: fontName),
          overline: base.overline?.copyWith(fontFamily: fontName),
        )
        .apply(bodyColor: normalText);
  }

  static ThemeData buildLightTheme() {
    final ThemeData base = ThemeData.light();
    final Color primaryColor = Color(0xFF30384D);
    // Color(0xff132137)
    final Color secondaryColor = Color(0xFF4A6572);
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      splashFactory: InkRipple.splashFactory,
      errorColor: Color(0xFFB00020),
      // textTheme: _buildTextTheme(base.textTheme),
      textTheme: GoogleFonts.wellfleetTextTheme(),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      platform: TargetPlatform.iOS,
    );
  }
}
