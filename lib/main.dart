import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_shorebired/app/theme/darkTheme.dart';
import 'package:getx_shorebired/app/theme/lightTheme.dart';
import 'package:getx_shorebired/app/theme/themecontroller.dart';
import 'package:getx_shorebired/data/services/service_Initializer.dart';
import 'package:getx_shorebired/home_page.dart';
import 'package:responsive_sizer/responsive_sizer.dart';


Future<void> main() async {
  await ServiceInitializer.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController _themeController = Get.find();
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'All Tests',
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: _themeController.isDarkMode.value?
                      ThemeMode.dark: ThemeMode.light,
          home:  HomePage(),
        );
      },
    );
  }
}

