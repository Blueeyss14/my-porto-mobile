import 'package:get/get.dart';
import 'package:my_portfolio/src/features/common/models/home_model.dart';
import 'package:my_portfolio/src/routes/routes_name.dart';

class HomeViewmodel extends GetxController {
  var home = <HomeModel>[].obs;

  @override
  void onInit() {
    pageData();
    super.onInit();
  }

  void pageData() {
    List<Map<String, dynamic>> pages = [
      {"page": "Background Page", "route": RoutesName.backgroundPage},
      {"page": "Message Page", "route": RoutesName.messagePage},
      {"page": "Song Page", "route": RoutesName.songPage},
      {"page": "Project Page", "route": RoutesName.projectPage},
    ];
    home.value = pages
        .map((page) => HomeModel(page['page'], page['route']))
        .toList();
  }
}
