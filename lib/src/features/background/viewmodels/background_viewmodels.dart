import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/background/models/background_model.dart';

class BackgroundViewmodels extends GetxController {
  var backgorundData = <BackgroundModel>[].obs;

  @override
  void onInit() {
    fetchBackground();
    super.onInit();
  }

  // JSON request headers
  Map<String, String> get jsonHeaders => {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };

  // Multipart headers (tanpa Content-Type manual)
  Map<String, String> get formHeaders => {
    'Authorization': dotenv.env['API_KEY'] ?? '',
  };

  Future<void> fetchBackground() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/mediaBackground'),
        headers: jsonHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body)['data'] as List;
        backgorundData.value = result
            .map<BackgroundModel>(
              (e) => BackgroundModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      } else {
        print('fetch failed ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('error fetch background $e');
    }
  }

  Future<void> createBackground(String filePath) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BASE_URL']}/mediaBackground'),
      );
      request.headers.addAll(formHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("create response: ${response.statusCode} $respStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Background uploaded successfully');
        fetchBackground();
      } else {
        Get.snackbar('Error', 'Failed to upload background');
      }
    } catch (e) {
      print('error create background $e');
      Get.snackbar('Error', 'Failed to upload background');
    }
  }

  Future<void> updateBackground(int id, String filePath) async {
    try {
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${dotenv.env['BASE_URL']}/mediaBackground/$id'),
      );
      request.headers.addAll(formHeaders);
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var response = await request.send();
      var respStr = await response.stream.bytesToString();
      print("update response: ${response.statusCode} $respStr");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Background updated successfully');
        fetchBackground();
      } else {
        Get.snackbar('Error', 'Failed to update background');
      }
    } catch (e) {
      print('error update background $e');
      Get.snackbar('Error', 'Failed to update background');
    }
  }

  Future<void> deleteBackground(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/mediaBackground/$id'),
        headers: jsonHeaders,
      );
      print("delete response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar('Success', 'Background deleted successfully');
        fetchBackground();
      } else {
        Get.snackbar('Error', 'Failed to delete background');
      }
    } catch (e) {
      print('error delete background $e');
      Get.snackbar('Error', 'Failed to delete background');
    }
  }
}
