import 'package:get/get.dart';
import 'package:my_portfolio/src/features/song/viewmodels/song_viewmodel.dart';

Future<void> refreshData() async {
  await Get.find<SongViewmodel>().fetchMusic();
}
