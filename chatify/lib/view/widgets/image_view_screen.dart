import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:gallery_saver_plus/gallery_saver.dart';
// import 'package:handyman/src/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class FullImageScreen extends StatelessWidget {
  final String id;
  final String image;
  const FullImageScreen({super.key, this.id = "", required this.image});

  downloadImage(context) async {
    if (await Permission.storage.request().isGranted) {
      try {
        // var response = await http.get(Uri.parse(image));
        // Directory documentDirectory = await getApplicationDocumentsDirectory();
        // File file = File(join(documentDirectory.path,
        //     "${DateTime.now().microsecondsSinceEpoch}.jpg"));

        // await file.writeAsBytes(response.bodyBytes);
        // await GallerySaver.saveImage(image, albumName: 'Handyman').then((_) {
        //   if (_ != null && _) {
        //     sendToast('Saved to gallery');
        //   } else {
        //     sendToast('Something went wrong...!');
        //   }
        // });
      } catch (e) {}
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        foregroundColor: Colors.white,
      ),
      body: SizedBox(
        width: context.width,
        child: image.contains("http")
            ? CachedNetworkImage(
                memCacheHeight: 1000,
                maxHeightDiskCache: 1000,
                maxWidthDiskCache: 1000,
                memCacheWidth: 1000,
                fit: BoxFit.fitWidth,
                imageUrl: image,
                imageBuilder: (context, imageProvider) => Hero(
                  transitionOnUserGestures: true,
                  key: UniqueKey(),
                  tag: id,
                  child: PhotoView(
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 2.0,
                    imageProvider: imageProvider,
                  ),
                ),
                errorWidget: (context, url, error) {
                  return const Padding(
                    padding: EdgeInsets.all(100.0),
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                    ),
                  );
                },
              )
            : Hero(
                transitionOnUserGestures: true,
                key: UniqueKey(),
                tag: id,
                child: PhotoView(
                  minScale: PhotoViewComputedScale.contained * 0.8,
                  maxScale: PhotoViewComputedScale.covered * 2.0,
                  initialScale: PhotoViewComputedScale.covered,
                  imageProvider: FileImage(File(image)),
                ),
              ),
      ),
    );
  }
}
