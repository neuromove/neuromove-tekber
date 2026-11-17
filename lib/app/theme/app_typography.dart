import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const poppins = 'Poppins';
  static const atkinson = 'AtkinsonHyperlegible';
  static const montserrat = 'Montserrat';

  static TextStyle poppinsStyle({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
  }) => TextStyle(
    fontFamily: poppins,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
