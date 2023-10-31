import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/data/db_models/db_message_model.dart';
import 'package:chatify/view/widgets/full_screen_video.dart';
import 'package:chatify/view/widgets/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/view/widgets/sizedBox.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_compress/video_compress.dart';
import 'clip_l_thread.dart';
import 'clip_r_thread.dart';

class MessageTile extends StatefulWidget {
  const MessageTile({
    Key? key,
    this.myMessage = true,
    this.firstMessage = true,
    required this.messageText,
    this.send = false,
    this.received = false,
    this.opened = false,
    this.index = 0,
    required this.dateTime,
    required this.messageType,
    this.filePath,
    required this.messageModel,
    required this.chatController,
  }) : super(key: key);

  final bool myMessage, firstMessage, send, received, opened;
  final String messageText;
  final int index;
  final String messageType;
  final String? filePath;
  final DateTime dateTime;
  final DbMessageModel messageModel;
  final ChatController chatController;

  @override
  State<MessageTile> createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  final msgType = ["text", "image", "video", "audio", "file", "document"];

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.myMessage ? Alignment.topRight : Alignment.topLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.myMessage && widget.firstMessage)
            ClipPath(
              clipper: ClipLThread(),
              child: Container(
                height: 10.0,
                width: 7.0,
                decoration: BoxDecoration(
                  color: widget.myMessage
                      ? MyColor.chatBoxColor
                      : MyColor.chatBoxColor1,
                ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
                minHeight: 40.0, maxWidth: Get.width * 0.75, minWidth: 80),
            // padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 8.0),
            decoration: BoxDecoration(
              color: widget.myMessage
                  ? MyColor.chatBoxColor
                  : MyColor.chatBoxColor1,
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(12.0),
                bottomRight: const Radius.circular(12.0),
                topRight: Radius.circular(
                    widget.firstMessage && widget.myMessage ? 0.0 : 12.0),
                topLeft: Radius.circular(
                    widget.firstMessage && !widget.myMessage ? 0.0 : 12.0),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 8,
                      bottom: (widget.messageType == "audio" ||
                              widget.messageType == "document")
                          ? 8
                          : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //
                      // image widget
                      //
                      if (widget.messageType == "image")
                        MessageTileImageWidget(widget: widget),
                      //
                      // video widget
                      //
                      if (widget.messageType == "video")
                        MessageTileVideoWidget(widget: widget),
                      //
                      // text widget
                      //
                      if (widget.messageType == "text" ||
                          !msgType.contains(widget.messageText.toLowerCase()))
                        Text(
                          widget.messageText,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            fontSize: 14.0,
                          ),
                        ),
                      //
                      // audio widget
                      //
                      if (widget.messageType == "audio")
                        MessageTileAudioWidget(widget: widget),
                      //
                      // file and document widget
                      //
                      if (widget.messageType == "document")
                        MessageTileDocumentWidget(widget: widget),
                      //
                      // Unsupported file type
                      //
                      if (!msgType.contains(widget.messageType.toLowerCase()))
                        const Text("Unsupported file type"),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.messageType == "audio")
                        Flexible(
                          child: Text(
                            path.basename(
                                widget.messageModel.fileLocalPath ?? ""),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 10.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                      if (widget.messageType == "audio") sizedBoxW8,
                      Text(
                        DateFormat("hh:mm a").format(widget.dateTime),
                        textAlign: TextAlign.start,
                        style: const TextStyle(fontSize: 10.0),
                      ),
                      sizedBoxW4,
                      if (widget.myMessage)
                        if (widget.opened)
                          const Icon(Icons.done_all,
                              size: 14.0, color: Colors.blue)
                        else if (widget.received)
                          const Icon(Icons.done_all, size: 14.0)
                        else
                          const Icon(Icons.check, size: 14.0)
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (widget.myMessage && widget.firstMessage)
            ClipPath(
              clipper: ClipRThread(),
              child: Container(
                height: 10.0,
                width: 10.0,
                decoration: BoxDecoration(
                    color: widget.myMessage
                        ? MyColor.chatBoxColor
                        : MyColor.chatBoxColor1),
              ),
            ),
        ],
      ),
    );
  }
}

class MessageTileDocumentWidget extends StatelessWidget {
  const MessageTileDocumentWidget({
    super.key,
    required this.widget,
  });

  final MessageTile widget;

  @override
  Widget build(BuildContext context) {
    return (widget.messageModel.fileLocalPath?.isNotEmpty ?? false)
        ? GestureDetector(
            onTap: () async {
              if (path
                      .extension(widget.messageModel.fileLocalPath ?? "")
                      .toLowerCase() ==
                  ".apk") {
                await Permission.requestInstallPackages.request();
              }

              await OpenFile.open(widget.messageModel.fileLocalPath ?? "");
            },
            child: SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(
                    Icons.insert_drive_file_rounded,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        path.basename(widget.messageModel.fileLocalPath ?? ""),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 15.0, fontWeight: FontWeight.w500),
                      ),
                      sizedBoxH4,
                      Row(
                        children: [
                          Text(
                            getFileSize(
                                widget.messageModel.fileLocalPath ?? ""),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 5),
                          const CircleAvatar(
                              radius: 3, backgroundColor: Colors.black),
                          const SizedBox(width: 5),
                          Text(
                            path
                                .extension(
                                    widget.messageModel.fileLocalPath ?? "")
                                .split('.')
                                .last
                                .toUpperCase(),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                fontSize: 13.0, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          )
        : Row(
            children: [
              Obx(() => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: MyColor.primaryColor,
                      shape: const CircleBorder()),
                  onPressed: widget.chatController.downloadingFile
                          .contains(widget.messageModel.id)
                      ? () {}
                      : () {
                          widget.chatController
                              .saveFileToDirectory(widget.messageModel);
                        },
                  child: widget.chatController.downloadingFile
                          .contains(widget.messageModel.id)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.download,
                          color: Colors.white,
                        ))),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    path.basename(widget.messageModel.filePath ?? ""),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 15.0, fontWeight: FontWeight.w500),
                  ),
                  Row(
                    children: [
                      const Text(
                        "0.0 MB",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 5),
                      const CircleAvatar(
                          radius: 3, backgroundColor: Colors.black),
                      const SizedBox(width: 5),
                      Text(
                        path
                            .extension(widget.messageModel.filePath ?? "")
                            .split('.')
                            .last
                            .toUpperCase(),
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 13.0, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              )
            ],
          );
  }
}

class MessageTileAudioWidget extends StatelessWidget {
  const MessageTileAudioWidget({
    super.key,
    required this.widget,
  });

  final MessageTile widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (widget.messageModel.fileLocalPath?.isNotEmpty ?? false)
          ? AudioPlayerWidget(
              chatController: widget.chatController,
              chatID: widget.messageModel.id,
              audioUrl: widget.messageModel.fileLocalPath!)
          : Row(
              children: [
                Obx(() => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: MyColor.primaryColor,
                        shape: const CircleBorder()),
                    onPressed: widget.chatController.downloadingFile
                            .contains(widget.messageModel.id)
                        ? () {}
                        : () {
                            widget.chatController
                                .saveFileToDirectory(widget.messageModel);
                          },
                    child: widget.chatController.downloadingFile
                            .contains(widget.messageModel.id)
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.download,
                            color: Colors.white,
                          ))),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: 7,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => SizedBox(
                        height: 40,
                        child: SvgPicture.asset(
                          "assets/sound.svg",
                          height: 40,
                          // ignore: deprecated_member_use
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class MessageTileVideoWidget extends StatelessWidget {
  const MessageTileVideoWidget({
    super.key,
    required this.widget,
  });

  final MessageTile widget;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: (widget.messageModel.fileLocalPath?.isNotEmpty ?? false)
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 250,
                width: double.maxFinite,
                color: Colors.grey.shade300,
                child: FutureBuilder<String>(
                  future:
                      createVideoThumbnail(widget.messageModel.fileLocalPath!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      final thumbnailFile = snapshot.data!;
                      return SizedBox(
                        height: 250,
                        width: double.maxFinite,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 250,
                              width: double.maxFinite,
                              child: Image.file(
                                File(thumbnailFile),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  Get.to(() => FullVideoScreen(
                                      file: File(
                                          widget.messageModel.fileLocalPath ??
                                              "")));
                                },
                                icon: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 65,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            )
          : DownloadViewWidget(widget: widget),
    );
  }
}

class MessageTileImageWidget extends StatelessWidget {
  const MessageTileImageWidget({
    super.key,
    required this.widget,
  });

  final MessageTile widget;

  @override
  Widget build(BuildContext context) {
    return (widget.messageModel.fileLocalPath?.isNotEmpty ?? false)
        ? SizedBox(
            height: 250,
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                Get.to(() => FullImageScreen(
                      image: widget.messageModel.fileLocalPath!,
                      id: "${widget.messageModel.fileLocalPath!}@@@",
                    ));
              },
              child: Hero(
                tag: "${widget.messageModel.fileLocalPath!}@@@",
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.messageModel.fileLocalPath!),
                    errorBuilder: (context, error, stackTrace) {
                      Box messageBox =
                          Hive.box<DbMessageModel>(DbNames.message);
                      DbMessageModel messageData =
                          messageBox.get(widget.messageModel.id);
                      messageData.fileLocalPath = "";
                      messageBox.put(messageData.id, messageData);

                      return Container(
                        height: double.infinity,
                        width: double.infinity,
                        color: Colors.grey.shade300,
                      );
                    },
                    cacheHeight: 500,
                    cacheWidth: 500,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          )
        : DownloadViewWidget(widget: widget);
  }
}

class DownloadViewWidget extends StatelessWidget {
  const DownloadViewWidget({
    super.key,
    required this.widget,
  });

  final MessageTile widget;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
        ),
        child: Container(
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: ExactAssetImage("assets/images/harry42.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 17, sigmaY: 17),
              child: Container(
                  alignment: Alignment.center,
                  color: Colors.grey.withOpacity(0.1),
                  child: Obx(() => !widget.chatController.downloadingFile
                          .contains(widget.messageModel.id)
                      ? ElevatedButton.icon(
                          onPressed: () {
                            widget.chatController
                                .saveFileToDirectory(widget.messageModel);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black.withOpacity(0.35)),
                          icon: const Icon(Icons.download),
                          label: const Text("Download"))
                      : const Center(
                          child: CircularProgressIndicator(),
                        ))),
            ),
          ),
        ),
      ),
    );
  }
}

Future<String> createVideoThumbnail(String videoPath) async {
  final thumbnail = await VideoCompress.getFileThumbnail(
    videoPath,
    quality: 100,
  );
  return thumbnail.path;
}

class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl, chatID;
  final ChatController chatController;
  const AudioPlayerWidget(
      {super.key,
      required this.audioUrl,
      required this.chatID,
      required this.chatController});

  @override
  // ignore: library_private_types_in_public_api
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with WidgetsBindingObserver {
  late AudioPlayer _audioPlayer;

  // bool _isPlaying = false;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.chatID != widget.chatController.currentlyPlayingAudio) {
      widget.chatController.position = Duration.zero;
    }
    WidgetsBinding.instance.addObserver(this);
    _initAudioPlayer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    } else {
      if (widget.chatID == widget.chatController.currentlyPlayingAudio) {
        _audioPlayer.pause();
      }
    }
  }

  void _initAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setFilePath(widget.audioUrl);
    if (widget.chatID == widget.chatController.currentlyPlayingAudio) {
      await _audioPlayer.seek(widget.chatController.position);
      await _audioPlayer.play();
      setState(() {});
    }
    _audioPlayer.setLoopMode(LoopMode.off);
    _audioPlayer.durationStream.listen((d) {
      if (d != null) {
        setState(() {
          _duration = d;
        });
      }
    });

    _audioPlayer.positionStream.listen((p) {
      if (widget.chatID != widget.chatController.currentlyPlayingAudio) {
        _audioPlayer.pause();
      }
      setState(() {
        widget.chatController.position = p;
      });
    });
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _stopAudioPlayer();
      }
    });
  }

  void _stopAudioPlayer() async {
    await _audioPlayer.pause();
    widget.chatController.currentlyPlayingAudio = '';
    _seekToSecond(0);
  }

  Future<void> _playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      widget.chatController.currentlyPlayingAudio = '';
    } else {
      widget.chatController.currentlyPlayingAudio = widget.chatID;
      await _audioPlayer.play();
    }
  }

  void _seekToSecond(double second) {
    Duration newPosition = Duration(seconds: second.toInt());
    _audioPlayer.seek(newPosition);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String minutes =
        duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
        duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: MyColor.primaryColor.withOpacity(0.8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 28,
                width: 28,
                child: Lottie.asset(
                  "assets/bars.json",
                  animate: _audioPlayer.playing ? true : false,
                ),
              ),
              Text(
                  _audioPlayer.playing
                      ? _formatDuration(widget.chatController.position)
                      : _formatDuration(_duration),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.65))
            ],
          ),
        ),
        GestureDetector(
          onTap: _playPause,
          child: Icon(
            _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
            size: 33,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
                inactiveTrackColor: Colors.grey.shade400,
                trackShape: const RoundedRectSliderTrackShape(),
                trackHeight: 4.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7.0),
                overlayShape: SliderComponentShape.noOverlay),
            child: Slider(
              value: widget.chatController.position.inSeconds.toDouble(),
              min: 0.0,
              // divisions: _duration.inSeconds.toInt(),
              // label: _formatDuration(_position),
              activeColor: Colors.orange,
              max: _duration.inSeconds.toDouble(),
              onChanged: (double value) {
                setState(() {
                  _seekToSecond(value);
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

String getFileSize(String filePath) {
  File file = File(filePath);
  int fileSizeInBytes = file.lengthSync();

  if (fileSizeInBytes < 1024) {
    return '$fileSizeInBytes B';
  } else if (fileSizeInBytes < (1024 * 1024)) {
    double fileSizeInKB = fileSizeInBytes / 1024;
    return '${fileSizeInKB.toStringAsFixed(2)} KB';
  } else {
    double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return '${fileSizeInMB.toStringAsFixed(2)} MB';
  }
}
