import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  /// Initializes the responsive utility with the current [BuildContext].
  /// This must be called at the root of the application.
  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  /// Scales the given [width] based on the design draft width (375px).
  static double setWidth(double width) {
    return (width / 375.0) * screenWidth;
  }

  /// Scales the given [height] based on the design draft height (812px).
  static double setHeight(double height) {
    return (height / 812.0) * screenHeight;
  }

  /// Scales the [fontSize] while maintaining aspect ratio between width and height.
  static double setSp(double fontSize) {
    double widthScale = screenWidth / 375.0;
    double heightScale = screenHeight / 812.0;
    return fontSize * (widthScale < heightScale ? widthScale : heightScale);
  }
}

/// Extension to provide easy access to responsive scaling on numeric values.
extension ResponsiveExtension on num {
  /// Adapts width based on screen size (e.g., 20.w)
  double get w => Responsive.setWidth(toDouble());
  
  /// Adapts height based on screen size (e.g., 50.h)
  double get h => Responsive.setHeight(toDouble());
  
  /// Adapts font size based on screen size (e.g., 16.sp)
  double get sp => Responsive.setSp(toDouble());
}
