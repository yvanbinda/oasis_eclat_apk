import 'package:get/get.dart';
import 'package:oasis_eclat/features/authentication/presentation/pages/login_page.dart';

part 'app_routes.dart';
class AppPages {
  static final routes = [
    GetPage(
        name: Routes.LOGIN,
        page: () => LoginPage(),
    )
  ];
}