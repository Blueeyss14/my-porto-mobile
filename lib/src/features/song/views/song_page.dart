import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_portfolio/src/core/refresh_data.dart';
import 'package:my_portfolio/src/features/song/viewmodels/song_viewmodel.dart';
import 'package:my_portfolio/src/features/song/models/song_model.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class SongPage extends StatelessWidget {
  const SongPage({super.key});

  @override
  Widget build(BuildContext context) {
    final songC = Get.find<SongViewmodel>();

    return Scaffold(
      appBar: const AppbarCustom(title: 'Song Page'),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Obx(() {
          return ListView.builder(
            itemCount: songC.songData.length,
            itemBuilder: (context, index) {
              final song = songC.songData[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(song.songFile), Text(song.songName)],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () =>
                                _showEditDialog(context, song, songC),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showDeleteDialog(context, song.id, songC),
                            icon: const Icon(Icons.delete),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, songC),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, SongViewmodel controller) {
    final nameController = TextEditingController();
    File? pickedFile;
    String selectedFileName = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Song Name'),
              ),
              const SizedBox(height: 10),
              if (selectedFileName.isNotEmpty)
                Text('Selected: $selectedFileName')
              else
                const Text('No file selected'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(type: FileType.audio);
                  if (result != null && result.files.single.path != null) {
                    pickedFile = File(result.files.single.path!);
                    setState(() {
                      selectedFileName = result.files.single.name;
                    });

                    if (Get.isSnackbarOpen) {
                      Get.closeAllSnackbars();
                    }

                    Future.delayed(const Duration(milliseconds: 100), () {
                      Get.snackbar(
                        'Success',
                        'Audio file selected',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 1),
                      );
                    });
                  }
                },
                child: const Text('Pick Audio File'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.closeAllSnackbars();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (pickedFile != null &&
                    nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();

                  if (Get.isSnackbarOpen) {
                    Get.closeAllSnackbars();
                  }

                  Get.dialog(
                    const Center(child: CircularProgressIndicator()),
                    barrierDismissible: false,
                  );

                  await controller.uploadSongFile(
                    pickedFile!,
                    nameController.text.trim(),
                  );

                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                } else {
                  if (Get.isSnackbarOpen) {
                    Get.closeAllSnackbars();
                  }

                  Get.snackbar(
                    'Error',
                    'Name or file missing',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    SongModel song,
    SongViewmodel controller,
  ) {
    final nameController = TextEditingController(text: song.songName);
    File? pickedFile;
    String selectedFileName = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Song'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Song Name'),
              ),
              const SizedBox(height: 10),
              if (selectedFileName.isNotEmpty)
                Text('Selected: $selectedFileName')
              else
                Text('Current: ${song.songFile}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  try {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.audio);
                    if (result != null && result.files.single.path != null) {
                      pickedFile = File(result.files.single.path!);
                      setState(() {
                        selectedFileName = result.files.single.name;
                      });

                      if (Get.isSnackbarOpen) {
                        Get.closeAllSnackbars();
                      }

                      Future.delayed(const Duration(milliseconds: 100), () {
                        Get.snackbar(
                          'Success',
                          'New audio file selected',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 1),
                        );
                      });
                    }
                  } catch (e) {
                    print('File picker error: $e');
                  }
                },
                child: const Text('Pick New Audio File (Optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (Get.isSnackbarOpen) {
                  Get.closeAllSnackbars();
                }
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  if (Get.isSnackbarOpen) {
                    Get.closeAllSnackbars();
                  }

                  Get.snackbar(
                    'Error',
                    'Song name cannot be empty',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                  );
                  return;
                }

                Navigator.of(context).pop();

                if (Get.isSnackbarOpen) {
                  Get.closeAllSnackbars();
                }

                await controller.editSong(
                  song.id,
                  nameController.text.trim(),
                  filePath: pickedFile?.path,
                );
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int id,
    SongViewmodel controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Song'),
        content: const Text('Are you sure you want to delete this song?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await controller.deleteSong(id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
