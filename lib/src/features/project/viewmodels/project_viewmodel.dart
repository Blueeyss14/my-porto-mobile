import 'dart:convert';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:my_portfolio/src/features/project/models/project_model.dart';
import 'package:http/http.dart' as http;

class ProjectViewmodel extends GetxController {
  var projectData = <ProjectModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    fetchProjects();
    super.onInit();
  }

  Map<String, String> headers = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
    'Content-Type': 'application/json',
  };
  Map<String, String> multipartHeaders = {
    'Authorization': dotenv.env['API_KEY'] ?? '',
  };

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['BASE_URL']}/projects'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body)['data'];
        projectData.value = result
            .map<ProjectModel>(
              (project) =>
                  ProjectModel.fromJson(project as Map<String, dynamic>),
            )
            .toList();
        projectData.sort((a, b) => a.id.compareTo(b.id));
        Get.snackbar('Success', 'Projects loaded successfully');
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch projects: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Fetch exception: $e');
    }
  }

  Future<void> addProject({
    required String title,
    required String subtitle,
    required String description,
    required String category,
    required bool isPinned,
    PlatformFile? thumbnail,
    List<PlatformFile>? imageFiles,
    List<String>? tags,
    List<Map<String, String>>? contributing,
    List<Map<String, String>>? resources,
  }) async {
    try {
      isLoading.value = true;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BASE_URL']}/projects'),
      );

      request.headers.addAll(multipartHeaders);

      request.fields['title'] = title;
      request.fields['subtitle'] = subtitle;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['is_pinned'] = isPinned.toString();

      ///thumbnail
      if (thumbnail != null &&
          thumbnail.bytes != null &&
          thumbnail.bytes!.isNotEmpty) {
        String contentType = _getContentType(thumbnail.extension);
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            thumbnail.bytes!,
            filename: thumbnail.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      ///images
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            String contentType = _getContentType(file.extension);
            request.files.add(
              http.MultipartFile.fromBytes(
                'image_url',
                file.bytes!,
                filename: file.name,
                contentType: MediaType.parse(contentType),
              ),
            );
          }
        }
      }

      if (tags != null && tags.isNotEmpty) {
        request.fields['tags'] = jsonEncode(tags);
      }
      if (contributing != null && contributing.isNotEmpty) {
        request.fields['contributing'] = jsonEncode(contributing);
      }
      if (resources != null && resources.isNotEmpty) {
        request.fields['resources'] = jsonEncode(resources);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          'Success',
          'Project added successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchProjects();
      } else {
        final errorData = () {
          try {
            return jsonDecode(responseBody);
          } catch (_) {
            return {'message': responseBody};
          }
        }();
        Get.snackbar(
          'Error',
          'Failed to add project: ${errorData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Add project exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> patchProject({
    required int id,
    String? title,
    String? subtitle,
    String? description,
    String? category,
    bool? isPinned,
    PlatformFile? thumbnail,
    List<PlatformFile>? imageFiles,
    int? imageIndex,
    int? deleteIndex,
    bool addImages = false,
    List<String>? tags,
    List<Map<String, String>>? contributing,
    List<Map<String, String>>? resources,
  }) async {
    try {
      isLoading.value = true;

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('${dotenv.env['BASE_URL']}/projects/$id'),
      );

      request.headers.addAll(multipartHeaders);

      if (title != null) request.fields['title'] = title;
      if (subtitle != null) request.fields['subtitle'] = subtitle;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;
      if (isPinned != null) request.fields['is_pinned'] = isPinned.toString();
      if (imageIndex != null) {
        request.fields['image_index'] = imageIndex.toString();
      }
      if (deleteIndex != null) {
        request.fields['delete_index'] = deleteIndex.toString();
      }
      if (addImages) request.fields['add_images'] = 'true';

      ///thumbnail
      if (thumbnail != null &&
          thumbnail.bytes != null &&
          thumbnail.bytes!.isNotEmpty) {
        String contentType = _getContentType(thumbnail.extension);
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            thumbnail.bytes!,
            filename: thumbnail.name,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

      //images
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (final file in imageFiles) {
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            String contentType = _getContentType(file.extension);
            request.files.add(
              http.MultipartFile.fromBytes(
                'image_url',
                file.bytes!,
                filename: file.name,
                contentType: MediaType.parse(contentType),
              ),
            );
          }
        }
      }

      if (tags != null) request.fields['tags'] = jsonEncode(tags);
      if (contributing != null) {
        request.fields['contributing'] = jsonEncode(contributing);
      }
      if (resources != null) {
        request.fields['resources'] = jsonEncode(resources);
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody);
        final index = projectData.indexWhere((p) => p.id == id);
        if (index != -1) {
          projectData[index] = ProjectModel.fromJson(result);
        }
        Get.snackbar(
          'Success',
          'Project updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        final errorData = jsonDecode(responseBody);
        Get.snackbar(
          'Error',
          'Failed to update project: ${errorData['error'] ?? 'Unknown error'}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Update project exception: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<PlatformFile?> pickSingleImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes == null && file.path != null && !kIsWeb) {
          try {
            final fileBytes = await File(file.path!).readAsBytes();
            return PlatformFile(
              name: file.name,
              size: file.size,
              bytes: fileBytes,
              path: file.path,
            );
          } catch (e) {
            Get.snackbar('Error', 'Could not read file: $e');
            return null;
          }
        }

        if (file.bytes == null || file.bytes!.isEmpty) {
          Get.snackbar('Error', 'Could not read file data');
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Error picking image: $e');
      return null;
    }
  }

  Future<List<PlatformFile>?> pickMultipleImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<PlatformFile> validFiles = [];

        for (final file in result.files) {
          PlatformFile? processedFile;

          if (file.bytes == null && file.path != null && !kIsWeb) {
            try {
              final fileBytes = await File(file.path!).readAsBytes();
              processedFile = PlatformFile(
                name: file.name,
                size: file.size,
                bytes: fileBytes,
                path: file.path,
              );
            } catch (e) {
              print('Could not read file ${file.name}: $e');
              continue;
            }
          } else {
            processedFile = file;
          }

          if (processedFile.bytes != null && processedFile.bytes!.isNotEmpty) {
            validFiles.add(processedFile);
          }
        }

        if (validFiles.isEmpty) {
          Get.snackbar('Error', 'Could not read any file data');
          return null;
        }

        return validFiles;
      }
      return null;
    } catch (e) {
      Get.snackbar('Error', 'Error picking images: $e');
      return null;
    }
  }

  String _getContentType(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> deleteData(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['BASE_URL']}/projects/$id/'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        projectData.removeWhere((item) => item.id == id);
        Get.snackbar('Success', 'Project deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Delete exception: $e');
    }
  }
}
