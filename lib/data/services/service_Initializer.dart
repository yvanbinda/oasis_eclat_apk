import 'package:get/get.dart';
import 'package:getx_shorebired/app/theme/themecontroller.dart';

class ServiceInitializer {
  static Future<void> init() async{
    Get.put(ThemeController());
  }
}