import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatify/data/repository/user_repository.dart';
import 'package:chatify/routes/routes_names.dart';
import 'package:chatify/view/widgets/common_dialog_box.dart';

class ProfileController extends GetxController {
  UserRepository userRepository = UserRepository();

  TextEditingController username = TextEditingController();

  RxString imageUrl = "".obs;

  Future<void> uploadProfileImage() async {
    XFile? imagePicker = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 30);

    if (imagePicker != null) {
      dynamic result =
          await userRepository.profileImageUpload(imagePicker.path);

      if (result.runtimeType.toString() == "Response") {
        var response = jsonDecode(result.body);

        imageUrl.value = response["ImageUrl"];
      }
    }
  }

  Future<void> navTOHomeScreen() async {
    if (username.text.isEmpty) {
      CommonDialogBoxes()
          .customDialog(title: "Please enter your name", getBackOK: true);
    } else {
      dynamic result = await userRepository.userNameUpdate(username.text);
      if (result.runtimeType.toString() == "Response")
        Get.offAllNamed(RoutesNames.indexPage);
    }
  }
}
