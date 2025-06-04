import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:getx_shorebired/app/theme/darkTheme.dart';
import 'package:getx_shorebired/app/theme/lightTheme.dart';
import 'package:getx_shorebired/core/app/constants.dart';

class ThemeController extends GetxController {
  var isDarkMode =  true.obs;

  @override
  void onInit() {
    super.onInit();
    _setInitialTheme();
  }

  /// Set the initial theme
  void _setInitialTheme() {
    final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
    isDarkMode.value = brightness == Brightness.dark;
  }

  /// Get the current theme
  ThemeData get theme => isDarkMode.value? darkMode : lightMode;

  /// Getter for the canvas color
  Color get colorCard => isDarkMode.value? Constants.darkCardColor : Colors.white;

}