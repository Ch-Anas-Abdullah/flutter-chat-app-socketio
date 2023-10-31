import 'dart:async';
import 'dart:io';

import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/data/db_models/db_user_model.dart';
import 'package:chatify/view/screens/camera_screen/camera_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stream_transform/stream_transform.dart' as str;
import 'dart:developer';

import 'package:chatify/controller/users_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/view/widgets/sizedBox.dart';
import 'dart:math' as math show pi;

import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MessageSendTile extends StatefulWidget {
  const MessageSendTile({
    Key? key,
    required this.chatController,
    required this.userId,
    required this.userController,
  }) : super(key: key);

  final ChatController chatController;
  final UsersController userController;
  final String userId;

  @override
  State<MessageSendTile> createState() => _MessageSendTileState();
}

class _MessageSendTileState extends State<MessageSendTile> {
  late final Debouncer _debouncer;
  @override
  void initState() {
    _debouncer = Debouncer(
      milliseconds: 3000,
      () {},
    );

    super.initState();
  }

  updateStatus() {
    if (widget.chatController.messageTextField.value.text.isEmpty) {
      widget.userController.updateUserStatus(true, "");
    } else if (widget.chatController.messageTextField.value.text.length >= 2) {
      widget.userController.updateUserStatus(true, widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0) +
          const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints:
                  const BoxConstraints(maxHeight: 130.0, minHeight: 45.0),
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      onPressed: () async {
                        widget.chatController.focusNode.unfocus();
                        await Future.delayed(const Duration(milliseconds: 400));
                        // focusNode.canRequestFocus = false;
                        widget.chatController.showEmojiPicker.value =
                            !widget.chatController.showEmojiPicker.value;
                        if (!widget.chatController.showEmojiPicker.value) {
                          widget.chatController.focusNode.requestFocus();
                        }
                      },
                      icon: Obx(
                        () => widget.chatController.showEmojiPicker.value
                            ? const Icon(
                                Icons.keyboard,
                                color: Colors.grey,
                                size: 26.0,
                              )
                            : const Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey,
                                size: 26.0,
                              ),
                      )),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextFormField(
                        controller:
                            widget.chatController.messageTextField.value,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        focusNode: widget.chatController.focusNode,
                        style: const TextStyle(fontSize: 16.0),
                        onChanged: (String value) {
                          widget.chatController.messageTextField
                              .update((val) {});
                          if (value.length == 1) {
                            widget.userController
                                .updateUserStatus(true, widget.userId);
                          }
                          _debouncer.run(() {
                            updateStatus();
                          });
                        },
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: "Message",
                          hintStyle:
                              TextStyle(fontSize: 16.0, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        builder: (context) => Container(
                          height: 258,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.all(15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MediaSelectorButton(
                                    onPressed: () async {
                                      Get.back();
                                      var files = await FilePicker.platform
                                          .pickFiles(allowedExtensions: [
                                        "pdf",
                                        "doc",
                                        "docx",
                                        "ppt",
                                        "pptx",
                                        "xls",
                                        "xlsx",
                                        "txt",
                                        "zip",
                                        "rar",
                                        "apk",
                                        "csv",
                                      ], type: FileType.custom);
                                      if (files != null) {
                                        for (var file in files.files) {
                                          await widget.chatController
                                              .sendChatFile(
                                                  widget.userId,
                                                  file.path.toString(),
                                                  "document",
                                                  "document");
                                        }
                                      }
                                    },
                                    fgClr: Colors.deepPurple,
                                    icon: Icons.file_copy,
                                    text: "Document",
                                  ),
                                  MediaSelectorButton(
                                    onPressed: () {
                                      Get.back();
                                      Get.to(() => CameraScreen(
                                            userId: widget.userId,
                                          ));
                                    },
                                    fgClr: Colors.redAccent,
                                    icon: Icons.camera_alt,
                                    text: "Camera",
                                  ),
                                  MediaSelectorButton(
                                    onPressed: () async {
                                      try {
                                        Get.back();
                                        var assets =
                                            await AssetPicker.pickAssets(
                                                context,
                                                pickerConfig: AssetPickerConfig(
                                                  maxAssets: 5,
                                                  requestType:
                                                      RequestType.image |
                                                          RequestType.video,
                                                ));
                                        if (assets != null) {
                                          for (var asset in assets) {
                                            String messageType =
                                                asset.type == AssetType.image
                                                    ? "image"
                                                    : "video";
                                            File? file = await asset.file;
                                            if (file != null) {
                                              await widget.chatController
                                                  .sendChatFile(
                                                      widget.userId,
                                                      file.path,
                                                      messageType,
                                                      messageType);
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        log(e.toString());
                                      }
                                    },
                                    fgClr: Colors.purple,
                                    icon: Icons.image,
                                    text: "Gallery",
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MediaSelectorButton(
                                    onPressed: () async {
                                      try {
                                        Permission.audio.request();
                                        Get.back();

                                        var assets =
                                            await AssetPicker.pickAssets(
                                                context,
                                                pickerConfig:
                                                    const AssetPickerConfig(
                                                        maxAssets: 5,
                                                        requestType:
                                                            RequestType.audio));
                                        if (assets != null) {
                                          for (var asset in assets) {
                                            File? file = await asset.file;
                                            if (file != null) {
                                              log(file.path.toString());
                                              await widget.chatController
                                                  .sendChatFile(
                                                      widget.userId,
                                                      file.path,
                                                      "audio",
                                                      "audio");
                                            }
                                          }
                                        }
                                      } catch (e) {
                                        log(e.toString());
                                      }
                                    },
                                    fgClr: Colors.orange,
                                    icon: Icons.headphones,
                                    text: "Audio",
                                  ),
                                  MediaSelectorButton(
                                    onPressed: () {},
                                    fgClr: Colors.green,
                                    icon: Icons.location_on,
                                    text: "Location",
                                  ),
                                  MediaSelectorButton(
                                    onPressed: () {},
                                    fgClr: Colors.blueAccent,
                                    icon: Icons.person,
                                    text: "Contact",
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    icon: Transform.rotate(
                      angle: math.pi / 0.8,
                      child: const Icon(
                        Icons.attach_file,
                        size: 28,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  sizedBoxW4,
                ],
              ),
            ),
          ),
          sizedBoxW4,
          CircleAvatar(
            radius: 22,
            backgroundColor: MyColor.secondaryColor,
            child: IconButton(
              onPressed: () => widget.chatController.sendMessage(widget.userId),
              icon: Obx(() => Icon(
                  widget.chatController.messageTextField.value.text
                          .trim()
                          .isEmpty
                      ? Icons.mic
                      : Icons.send,
                  size: 25.0,
                  color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class Debouncer {
  final int milliseconds;
  final VoidCallback action;
  Timer? _timer;

  Debouncer(this.action, {required this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer?.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class MediaSelectorButton extends StatelessWidget {
  final IconData icon;
  final Color fgClr;
  final String text;
  final VoidCallback onPressed;
  const MediaSelectorButton({
    super.key,
    required this.icon,
    required this.fgClr,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                alignment: Alignment.center,
                fixedSize: const Size(60, 60),
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                backgroundColor: fgClr,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent),
            onPressed: onPressed,
            child: Icon(
              icon,
              size: 33,
            )),
        const SizedBox(height: 5),
        Text(text)
      ],
    );
  }
}
