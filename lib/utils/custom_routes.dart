import 'package:flutter/material.dart';

class CustomRoutes<T> extends MaterialPageRoute<T> {
  CustomRoutes({required super.builder});

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Don't animate or do nothing if InitialRoute.
    if (settings.name == '/') {
      return child;
    }

    // If other screens
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
      PageRoute<T> route,
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    // Same Code with [CustomRoutes]
    // Don't animate or do nothing if InitialRoute.
    if (route.settings.name == '/') {
      return child;
    }

    // If other screens
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}
