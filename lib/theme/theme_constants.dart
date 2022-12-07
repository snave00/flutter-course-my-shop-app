import 'package:flutter/material.dart';
import '../utils/custom_routes.dart';

PageTransitionsTheme myPageTransitionTheme = PageTransitionsTheme(builders: {
  // Can be different across target platform
  TargetPlatform.android: CustomPageTransitionBuilder(),
  TargetPlatform.iOS: CustomPageTransitionBuilder(),
});
