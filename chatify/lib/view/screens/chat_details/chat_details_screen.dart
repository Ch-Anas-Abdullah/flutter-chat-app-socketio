import 'dart:io';

import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/data/db_models/db_chat_list_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/view/screens/chat_details/components/message_list.dart';
import 'package:chatify/view/screens/chat_details/components/message_send_tile.dart';
import 'package:chatify/view/screens/chat_details/widgets/chat_user_header.dart';
import 'package:chatify/view/widgets/sizedBox.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatScreen(
      {Key? key,
      required this.userId,
      required this.userName,
      required this.userImage,
      required this.homeInstance})
      : super(key: key);

  final String userId, userName;
  final String userImage;
  final UsersController homeInstance;
  ChatController chatController = Get.put(ChatController());
  UsersController userController = Get.put(UsersController());

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    widget.chatController.userID = widget.userId;
    super.initState();
  }

  @override
  void dispose() {
    widget.chatController.userID = "";
    widget.chatController.currentlyPlayingAudio = "";
    widget.chatController.position = Duration.zero;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.chatController.showEmojiPicker.value) {
          widget.chatController.showEmojiPicker.value = false;
        } else {
          widget.homeInstance.getChatList();
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 12.0,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )),
          leading: IconButton(
            onPressed: () {
              widget.homeInstance.getChatList();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 70,
          flexibleSpace: ClipRRect(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            child: SizedBox(
                child: Image.asset(
              "assets/bg.png",
              fit: BoxFit.cover,
              width: double.infinity,
            )),
          ),
          title: Row(
            children: [
              widget.userImage.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(150),
                      child: CachedNetworkImage(
                        height: 42,
                        width: 42,
                        fit: BoxFit.cover,
                        imageUrl: widget.userImage,
                        useOldImageOnUrlChange: true,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ))
                  : Container(
                      height: 42.0,
                      width: 42.0,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300, shape: BoxShape.circle),
                      child: const Icon(Icons.person,
                          size: 35.0, color: Colors.white),
                    ),
              sizedBoxW8,
              Flexible(
                child: ChatUserHeader(
                    userName: widget.userName,
                    chatController: widget.chatController),
              ),
            ],
          ),
          leadingWidth: 25.0,
          actions: [
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.videocam_sharp)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
            // IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
          ],
        ),
        body: Column(
          children: [
            MessageList(
                userId: widget.userId,
                userController: widget.userController,
                chatController: widget.chatController),
            MessageSendTile(
                userController: widget.userController,
                chatController: widget.chatController,
                userId: widget.userId),
            Obx(() => widget.chatController.showEmojiPicker.value
                ? SizedBox(height: 300, child: emojiPick())
                : Container())
          ],
        ),
      ),
    );
  }

  Widget emojiPick() {
    return EmojiPicker(
      onEmojiSelected: (category, emoji) {
        widget.chatController.messageTextField.update((val) {});
      },

      onBackspacePressed: () {
        widget.chatController.messageTextField.update((val) {});
        // Do something when the user taps the backspace button (optional)
        // Set it to null to hide the Backspace-Button
      },
      textEditingController: widget.chatController.messageTextField
          .value, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
      config: Config(
        columns: 7,
        emojiSizeMax: 32 *
            (foundation.defaultTargetPlatform == TargetPlatform.iOS
                ? 1.30
                : 1.0),
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.RECENT,
        bgColor: const Color(0xFFF2F2F2),
        indicatorColor: MyColor.primaryColor,
        iconColor: Colors.grey,
        iconColorSelected: MyColor.primaryColor,
        backspaceColor: MyColor.primaryColor,
        skinToneDialogBgColor: Colors.white,
        skinToneIndicatorColor: Colors.grey,
        enableSkinTones: true,
        recentTabBehavior: RecentTabBehavior.RECENT,
        recentsLimit: 28,
        noRecents: const Text(
          'No Recents',
          style: TextStyle(fontSize: 20, color: Colors.black26),
          textAlign: TextAlign.center,
        ), // Needs to be const Widget
        loadingIndicator: const SizedBox.shrink(), // Needs to be const Widget
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const CategoryIcons(),

        buttonMode: ButtonMode.MATERIAL,
      ),
    );
  }
}
