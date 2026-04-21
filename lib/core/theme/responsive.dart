import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  // Scaling factor for width
  static double setWidth(double width) {
    return (width / 375.0) * screenWidth;
  }

  // Scaling factor for height
  static double setHeight(double height) {
    return (height / 812.0) * screenHeight;
  }

  // Scaling factor for text
  static double setSp(double fontSize) {
    double widthScale = screenWidth / 375.0;
    double heightScale = screenHeight / 812.0;
    return fontSize * (widthScale < heightScale ? widthScale : heightScale);
  }
}

extension ResponsiveExtension on num {
  double get w => Responsive.setWidth(toDouble());
  double get h => Responsive.setHeight(toDouble());
  double get sp => Responsive.setSp(toDouble());
}
