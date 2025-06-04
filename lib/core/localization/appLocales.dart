import 'dart:io';

import 'package:flutter/material.dart';

final deviceLocale = _getDeviceLocale();
final fallbackLocale = AppLocales.en;

class AppLocales {
  static const en = Locale('en', 'US');
  static const fr = Locale('fr', 'FR');

  static final List<Locale> supported = [en, fr];
}

/// Get device locale or null if unsupported
Locale? _getDeviceLocale() {
  final systemLocale = Platform.localeName;
  final languageCode = systemLocale.split('_')[0];
  
  return AppLocales.supported.firstWhere(
      (locale) => locale.languageCode == languageCode,
    // orElse: () => null,
  );
}