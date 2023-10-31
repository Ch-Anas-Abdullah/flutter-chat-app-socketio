import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/view/widgets/sizedBox.dart';

class CommonDialogBoxes {
  void customDialog({
    required String title,
    List<Widget>? action,
    bool getBackOK = false,
  }) {
    Get.dialog(
      AlertDialog(
        title: Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
        ),
        actions: [
          if (action != null) ...action,
          if (getBackOK)
            TextButton(
              onPressed: Get.back,
              child: const Text("OK",
                  style: TextStyle(color: MyColor.buttonColor)),
            )
        ],
      ),
    );
  }

  void loadingDialog() {
    Get.dialog(
      const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: MyColor.buttonColor),
            sizedBoxW16,
            Text("Connecting...")
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
