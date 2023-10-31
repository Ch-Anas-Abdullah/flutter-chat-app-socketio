// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:chatify/view/screens/camera_screen/preview_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/context_extensions.dart';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  final String? userId;
  const CameraScreen({super.key, this.userId});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation _animation;
  late CameraController _cameraController;
  late Future cameraVal;
  bool isFrontCamera = false;
  bool isVideoRecording = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cameraController = CameraController(
        cameras[isFrontCamera ? 1 : 0], ResolutionPreset.veryHigh);
    cameraVal = _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraController.resumePreview();
      setState(() {});
    } else {
      _cameraController.pausePreview();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _animationController.dispose();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: double.infinity,
        width: context.width,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: [
                  FutureBuilder(
                      future: cameraVal,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (_cameraController.value.isPreviewPaused) {}
                          return SizedBox(
                              height: isFrontCamera ? null : context.height,
                              width: context.width,
                              child: CameraPreview(_cameraController));
                        }
                        return Container(
                          height: context.height,
                          width: context.width,
                          color: Colors.black,
                        );
                      }),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.6),
                          radius: 25,
                          child: IconButton(
                              onPressed: () async {
                                switch (_cameraController.value.flashMode) {
                                  case FlashMode.auto:
                                    await _cameraController
                                        .setFlashMode(FlashMode.always);
                                    break;
                                  case FlashMode.always:
                                    await _cameraController
                                        .setFlashMode(FlashMode.off);
                                    break;
                                  case FlashMode.off:
                                    await _cameraController
                                        .setFlashMode(FlashMode.torch);
                                    break;
                                  case FlashMode.torch:
                                    await _cameraController
                                        .setFlashMode(FlashMode.auto);
                                    break;
                                  default:
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                _cameraController.value.flashMode ==
                                        FlashMode.auto
                                    ? Icons.flash_auto
                                    : _cameraController.value.flashMode ==
                                            FlashMode.off
                                        ? Icons.flash_off
                                        : _cameraController.value.flashMode ==
                                                FlashMode.always
                                            ? Icons.flash_on
                                            : _cameraController
                                                        .value.flashMode ==
                                                    FlashMode.torch
                                                ? Icons.flashlight_on
                                                : Icons.flash_on,
                                color: Colors.white,
                              )),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (!isVideoRecording) {
                              await _cameraController
                                  .setFocusMode(FocusMode.auto);
                              var file = await _cameraController.takePicture();
                              setState(() {
                                isLoading = true;
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CameraPreviewScreen(
                                        userId: widget.userId,
                                        file: File(file.path),
                                        isVideo: false),
                                  ));
                            }
                          },
                          onLongPress: () async {
                            setState(() {
                              isVideoRecording = true;
                            });
                            await _cameraController.startVideoRecording();
                          },
                          onLongPressUp: () async {
                            setState(() {
                              isVideoRecording = false;
                              isLoading = true;
                            });
                            var file =
                                await _cameraController.stopVideoRecording();

                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CameraPreviewScreen(
                                      userId: widget.userId,
                                      file: File(file.path),
                                      isVideo: true),
                                ));
                          },
                          child: Icon(
                            Icons.radio_button_on_sharp,
                            size: 80,
                            color: isVideoRecording ? Colors.red : Colors.white,
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (BuildContext context, Widget? child) {
                            return Transform(
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(_animation.value * 3.14),
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                          child: CircleAvatar(
                            backgroundColor: Colors.black.withOpacity(0.6),
                            radius: 25,
                            child: IconButton(
                                onPressed: () async {
                                  if (_animationController.isCompleted) {
                                    _animationController.reverse();
                                  } else {
                                    _animationController.forward();
                                  }
                                  isFrontCamera = !isFrontCamera;
                                  _cameraController = CameraController(
                                      cameras[isFrontCamera ? 1 : 0],
                                      ResolutionPreset.high);
                                  cameraVal =
                                      _cameraController.initialize().then((_) {
                                    if (!mounted) {
                                      return;
                                    }
                                    setState(() {});
                                  });
                                },
                                icon: const Icon(
                                  Icons.flip_camera_android,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
