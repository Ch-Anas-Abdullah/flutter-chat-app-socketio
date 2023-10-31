import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/profile_controller.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/common_scaffold.dart';
import 'package:chatify/view/widgets/sizedBox.dart';

class InitialProfileScreen extends StatelessWidget {
  const InitialProfileScreen({Key? key}) : super(key: key);

  static ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.primaryColor,
      body: SingleChildScrollView(
        // physics: const PageScrollPhysics(),
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                  height: context.height,
                  width: context.width,
                  child: Image.asset(
                    "assets/bg.png",
                    fit: BoxFit.fill,
                    height: context.height,
                    width: context.width,
                  )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
                child: Column(
                  children: [
                    const Text(
                      "Profile Info",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    sizedBoxH16,
                    const Text(
                        "Please provide your name and an optional profile photo",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                    sizedBoxH32,
                    GestureDetector(
                      onTap: () => profileController.uploadProfileImage(),
                      child: Obx(
                        () => Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade300,
                            image: profileController.imageUrl.value.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(
                                        profileController.imageUrl.value),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: profileController.imageUrl.value.isNotEmpty
                              ? null
                              : const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 50.0,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                    ),
                    sizedBoxH32,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: profileController.username,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.bottom,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                  hintText: "Type your name here",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade400),
                                  enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: MyColor.buttonColor)),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: MyColor.buttonColor))),
                            ),
                          ),
                          // const Icon(Icons.emoji_emotions_outlined, color: Colors.grey)
                        ],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => profileController.navTOHomeScreen(),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => MyColor.buttonColor),
                        padding: MaterialStateProperty.resolveWith((states) =>
                            const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 72.0)),
                      ),
                      child: const Text("Continue",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    sizedBoxH16,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
