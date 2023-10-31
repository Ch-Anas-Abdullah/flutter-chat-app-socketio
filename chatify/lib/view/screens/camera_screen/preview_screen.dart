import 'dart:developer';
import 'dart:io';

import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/view/screens/camera_screen/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class CameraPreviewScreen extends StatefulWidget {
  final File file;
  final bool isVideo;
  final String? userId;
  const CameraPreviewScreen(
      {super.key, required this.file, required this.isVideo, this.userId});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  TextEditingController messageTextController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  ChatController chatController = Get.put(ChatController());
  late Future videoInitialize;
  bool isSending = false;
  @override
  void initState() {
    if (widget.isVideo) {
      _videoPlayerController = VideoPlayerController.file(widget.file);
      videoInitialize = _videoPlayerController.initialize();
    }
    super.initState();
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          return await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(userId: widget.userId),
              ));
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            systemOverlayStyle:
                const SystemUiOverlayStyle(statusBarColor: Colors.black),
            foregroundColor: Colors.white,
            leading: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CameraScreen(userId: widget.userId),
                      ));
                },
                icon: const Icon(Icons.arrow_back_rounded)),
            actions: [
              // IconButton(
              //     onPressed: () {}, icon: const Icon(Icons.crop_rotate_sharp)),
              // IconButton(
              //     onPressed: () {},
              //     icon: const Icon(Icons.emoji_emotions_outlined)),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.title)),
              // IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
            ],
          ),
          backgroundColor: Colors.black,
          body: isSending
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox(
                  height: context.height,
                  width: context.width,
                  child: Stack(
                    children: [
                      if (!widget.isVideo)
                        Center(
                          child: SizedBox(
                            width: context.width,
                            child: Image.file(
                              widget.file,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (widget.isVideo)
                        Center(
                          child: SizedBox(
                            width: context.width,
                            child: FutureBuilder(
                                future: videoInitialize,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.done) {
                                    _videoPlayerController.addListener(() {
                                      setState(() {});
                                    });
                                    return SizedBox(
                                        width: context.width,
                                        child: Stack(
                                          children: [
                                            Center(
                                                child: VideoPlayer(
                                                    _videoPlayerController)),
                                            Center(
                                                child: CircleAvatar(
                                              backgroundColor: Colors.black45,
                                              radius: 33,
                                              child: IconButton(
                                                  onPressed: () async {
                                                    _videoPlayerController
                                                            .value.isPlaying
                                                        ? await _videoPlayerController
                                                            .pause()
                                                        : await _videoPlayerController
                                                            .play();
                                                    setState(() {});
                                                  },
                                                  icon: Icon(
                                                    _videoPlayerController
                                                            .value.isPlaying
                                                        ? Icons.pause
                                                        : Icons.play_arrow,
                                                    color: Colors.white,
                                                    size: 35,
                                                  )),
                                            )),
                                          ],
                                        ));
                                  }
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }),
                          ),
                        ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.only(bottom: 10, left: 10),
                              padding: EdgeInsets.zero,
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Flexible(
                                      child: TextFormField(
                                    controller: messageTextController,
                                    onChanged: (value) => setState(() {}),
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(color: Colors.white),
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 5,
                                    minLines: 1,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      isCollapsed: true,
                                      filled: true,
                                      fillColor:
                                          const Color.fromARGB(255, 10, 10, 10),
                                      hintText: "Add Caption...",
                                      hintStyle:
                                          const TextStyle(color: Colors.white),
                                      prefixIcon: IconButton(
                                          onPressed: () async {
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CameraScreen(
                                                          userId:
                                                              widget.userId),
                                                ));
                                          },
                                          icon: const Icon(
                                            Icons.photo,
                                            size: 28,
                                            color: Colors.white,
                                          )),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                      disabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                      errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                              color: Colors.black87)),
                                    ),
                                  )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          alignment: Alignment.center,
                                          fixedSize: const Size(50, 50),
                                          padding: EdgeInsets.zero,
                                          shape: const CircleBorder(),
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shadowColor: Colors.transparent),
                                      onPressed: () async {
                                        log(widget.file.path.toString());
                                        if (widget.userId != null) {
                                          setState(() {
                                            isSending = true;
                                          });
                                          if (widget.isVideo) {
                                            chatController.sendChatFile(
                                                widget.userId!,
                                                widget.file.path,
                                                messageTextController
                                                        .text.isEmpty
                                                    ? "VIDEO"
                                                    : messageTextController
                                                        .text,
                                                "video");
                                            await Future.delayed(
                                                const Duration(seconds: 2),
                                                () => Get.back());
                                          } else {
                                            chatController.sendChatFile(
                                                widget.userId!,
                                                widget.file.path,
                                                messageTextController
                                                        .text.isEmpty
                                                    ? "IMAGE"
                                                    : messageTextController
                                                        .text,
                                                "image");
                                            Get.back();
                                          }
                                        }
                                      },
                                      child: const Icon(Icons.check))
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
