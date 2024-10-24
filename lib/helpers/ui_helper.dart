import 'package:flutter/material.dart';

class UiHelper {
  static Route animatedRoute(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: secondaryAnimation,
            child: child,
          ),
        );
      },
    );
  }

  // Returns the smaller of the procided width and the width of the screen (with the factor in consideration)
  static double minWidth(BuildContext context, double width,
      {double? widthFactor}) {
    widthFactor ??= 1;
    if (MediaQuery.sizeOf(context).width < width) {
      return MediaQuery.sizeOf(context).width * widthFactor;
    }
    return width;
  }

  // Returns the larger of the procided width and the width of the screen (with the factor in consideration)
  static double maxWidth(BuildContext context, double width,
      {double? widthFactor}) {
    widthFactor ??= 1;
    if (MediaQuery.sizeOf(context).width < width) {
      return width;
    }
    return MediaQuery.sizeOf(context).width * widthFactor;
  }
}
