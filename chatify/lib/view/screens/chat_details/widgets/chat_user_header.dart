import 'package:chatify/controller/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/controller/chat_controller.dart';

class ChatUserHeader extends StatelessWidget {
  const ChatUserHeader({
    Key? key,
    required this.userName,
    required this.chatController,
  }) : super(key: key);

  final String userName;
  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.put(UsersController());
    usersController.getMyDetails();
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(userName, style: const TextStyle(fontSize: 16.0)),
        Obx(() => chatController.typing.value ==
                usersController.userId.value.toString()
            ? const Text("Typing...", style: TextStyle(fontSize: 12.0))
            : chatController.userStatus.value
                ? const Text("Online", style: TextStyle(fontSize: 12.0))
                : const Text("Offline", style: TextStyle(fontSize: 12.0))),
      ],
    );
  }
}
