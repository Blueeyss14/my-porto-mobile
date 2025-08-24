import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:my_portfolio/src/features/message/viewmodels/message_viemodel.dart';
import 'package:my_portfolio/src/shared/components/appbar_custom.dart';

class MessagePage extends StatelessWidget {
  const MessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final messageC = Get.find<MessageViemodel>();

    void showEditDialog(int index) {
      final userController = TextEditingController(
        text: messageC.messageData[index].userName,
      );
      final messageController = TextEditingController(
        text: messageC.messageData[index].message,
      );

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Edit Message'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: userController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                messageC.putMessage(
                  messageC.messageData[index].id,
                  userController.text,
                  messageController.text,
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    void showDeleteDialog(int index) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                messageC.deleteData(messageC.messageData[index].id);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AppbarCustom(title: 'Message Page'),
      body: RefreshIndicator(
        onRefresh: () async {
          messageC.fetchMessage();
        },
        child: Obx(
          () => ListView.builder(
            itemCount: messageC.messageData.length,
            itemBuilder: (context, index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            messageC.messageData[index].userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(messageC.messageData[index].message),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => showEditDialog(index),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => showDeleteDialog(index),
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
