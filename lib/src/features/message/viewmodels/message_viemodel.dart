import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:my_portfolio/src/features/message/models/message_model.dart';
import 'package:http/http.dart' as http;

class MessageViemodel extends GetxController {
  var messageData = <MessageModel>[].obs;

  @override
  void onInit() {
    fetchMessage();
    super.onInit();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };

  Future<void> fetchMessage() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/messages'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body)['data'];
        messageData.value = result
            .map<MessageModel>(
              (chat) => MessageModel.fromJson(chat as Map<String, dynamic>),
            )
            .toList();
        Get.snackbar(
          'Success',
          'Messages loaded successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch messages: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Fetch exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> putMessage(int id, String userName, String message) async {
    try {
      final response = await http.put(
        Uri.parse('${dotenv.env['BASE_URL']}/messages/$id/'),
        headers: headers,
        body: jsonEncode({'user_name': userName, 'message': message}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        final index = messageData.indexWhere((item) => item.id == id);
        if (index != -1) {
          messageData[index] = MessageModel(
            id: id,
            userName: userName,
            message: message,
          );
          messageData.refresh();
          Get.snackbar(
            'Success',
            'Message updated successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to update: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteData(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/messages/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        messageData.removeWhere((item) => item.id == id);
        Get.snackbar(
          'Success',
          'Message deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Delete exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
