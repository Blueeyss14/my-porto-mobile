import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_portfolio/src/features/background/viewmodels/background_viewmodels.dart';
import 'package:my_portfolio/src/features/background/models/background_model.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class BackgroundPage extends StatelessWidget {
  const BackgroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final backgroundC = Get.find<BackgroundViewmodels>();
    return Scaffold(
      appBar: const AppbarCustom(title: 'Background Page'),
      body: Obx(() {
        return ListView.builder(
          itemCount: backgroundC.backgorundData.length,
          itemBuilder: (context, index) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(backgroundC.backgorundData[index].filename),
                      Text(backgroundC.backgorundData[index].mimetype),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => _showEditDialog(
                          context,
                          backgroundC.backgorundData[index],
                          backgroundC,
                        ),
                        icon: const Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () => _showDeleteDialog(
                          context,
                          backgroundC.backgorundData[index].id,
                          backgroundC,
                        ),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, backgroundC),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, BackgroundViewmodels controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Background'),
        content: const Text('Select image or video file'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.media,
              );
              if (result != null && result.files.single.path != null) {
                controller.createBackground(result.files.single.path!);
                Get.back();
              }
            },
            child: const Text('Pick File'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    BackgroundModel background,
    BackgroundViewmodels controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Background'),
        content: Text('Replace: ${background.filename}'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.media,
              );
              if (result != null && result.files.single.path != null) {
                controller.updateBackground(
                  background.id,
                  result.files.single.path!,
                );
                Get.back();
              }
            },
            child: const Text('Pick New File'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    int id,
    BackgroundViewmodels controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Background'),
        content: const Text('Are you sure you want to delete this background?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              controller.deleteBackground(id);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
