import 'package:get/get.dart';
import 'package:oasis_eclat/app/theme/themecontroller.dart';
import 'package:oasis_eclat/features/app/controllers/homeController.dart';

class ServiceInitializer {
  static Future<void> init() async{
    Get.put(ThemeController());
    Get.put(HomeController());
  }
}