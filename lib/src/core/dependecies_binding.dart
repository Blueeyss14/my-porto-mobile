import 'package:get/get.dart';
import 'package:my_portfolio/src/features/background/viewmodels/background_viewmodels.dart';
import 'package:my_portfolio/src/features/common/viewmodels/home_viewmodel.dart';
import 'package:my_portfolio/src/features/message/viewmodels/message_viemodel.dart';

void initDependencies() {
  Get.put(HomeViewmodel());
  Get.put(BackgroundViewmodels());
  Get.put(MessageViemodel());
}
