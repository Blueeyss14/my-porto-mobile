import 'package:get/route_manager.dart';
import 'package:my_portfolio/src/features/common/views/home_page.dart';
import 'package:my_portfolio/src/routes/routes_name.dart';

class RoutesPage {
  static final pages = [
    GetPage(
      name: RoutesName.home,
      page: () => const HomePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
