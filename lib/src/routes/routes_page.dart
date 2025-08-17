import 'package:get/route_manager.dart';
import 'package:my_portfolio/src/features/background/views/background_page.dart';
import 'package:my_portfolio/src/features/common/views/home_page.dart';
import 'package:my_portfolio/src/features/message/views/message_page.dart';
import 'package:my_portfolio/src/features/project/views/project_page.dart';
import 'package:my_portfolio/src/features/song/views/song_page.dart';
import 'package:my_portfolio/src/routes/routes_name.dart';

class RoutesPage {
  static final pages = [
    GetPage(
      name: RoutesName.home,
      page: () => const HomePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: RoutesName.backgroundPage,
      page: () => const BackgroundPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: RoutesName.messagePage,
      page: () => const MessagePage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: RoutesName.songPage,
      page: () => const SongPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: RoutesName.projectPage,
      page: () => const ProjectPage(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
