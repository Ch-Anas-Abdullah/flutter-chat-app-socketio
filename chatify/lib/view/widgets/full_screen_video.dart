import 'dart:developer';
import 'dart:io';

import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/view/screens/camera_screen/camera_screen.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class FullVideoScreen extends StatefulWidget {
  final File file;

  const FullVideoScreen({super.key, required this.file});

  @override
  State<FullVideoScreen> createState() => _FullVideoScreenState();
}

class _FullVideoScreenState extends State<FullVideoScreen> {
  TextEditingController messageTextController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  ChatController chatController = Get.put(ChatController());
  late Future videoInitialize;
  bool isSending = false;
  @override
  void initState() {
    _videoPlayerController = VideoPlayerController.file(widget.file);
    videoInitialize = _videoPlayerController.initialize();

    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: context.height,
          width: context.width,
          child: Stack(
            children: [
              FutureBuilder(
                  future: videoInitialize,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      final chewieController = ChewieController(
                        videoPlayerController: _videoPlayerController,
                        autoPlay: true,
                        showOptions: false,
                        controlsSafeAreaMinimum: EdgeInsets.zero,
                        zoomAndPan: true,
                        draggableProgressBar: true,
                        materialProgressColors: ChewieProgressColors(
                          playedColor: Colors.purple,
                          handleColor: Colors.purple.shade600,
                          backgroundColor: Colors.grey,
                          bufferedColor: Colors.white,
                        ),
                      );
                      return SizedBox(
                        width: context.width,
                        child: Chewie(
                          controller: chewieController,
                        ),
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  }),
              Positioned(
                left: 15,
                top: 45,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      alignment: Alignment.center,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                      backgroundColor: Colors.grey.shade800.withAlpha(170),
                      padding: EdgeInsets.zero,
                      maximumSize: const Size(37, 37),
                      minimumSize: const Size(37, 37),
                      shape: const CircleBorder()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 37,
                    height: 37,
                    child: const Icon(
                      Icons.keyboard_backspace,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
