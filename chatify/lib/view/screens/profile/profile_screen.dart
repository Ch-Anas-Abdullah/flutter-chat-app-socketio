import 'package:chatify/controller/profile_controller.dart';
import 'package:chatify/data/repository/user_repository.dart';
import 'package:chatify/view/widgets/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/no_user_image.dart';
import 'package:chatify/view/widgets/sizedBox.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    UsersController usersController = Get.put(UsersController());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        )),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
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
        title: const Text(
          "Profile Info",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 16.0),
        children: [
          Center(
            child: Obx(
              () => Stack(
                children: [
                  if (usersController.userData.value.image != null &&
                      usersController.userData.value.image!.isEmpty)
                    NoUserImage(containerSize: width / 2.1, iconSize: width / 4)
                  else
                    Hero(
                      tag: "editProfile",
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey)),
                            child: GestureDetector(
                              onTap: (usersController.userData.value.image ==
                                          null ||
                                      (usersController
                                              .userData.value.image?.isEmpty ??
                                          true))
                                  ? null
                                  : () => Get.to(FullImageScreen(
                                      image: usersController
                                              .userData.value.image ??
                                          "")),
                              child: CachedNetworkImage(
                                height: 160,
                                width: 160,
                                fit: BoxFit.cover,
                                imageUrl:
                                    usersController.userData.value.image ??
                                        "no link",
                                memCacheHeight: 600,
                                memCacheWidth: 600,
                                maxHeightDiskCache: 600,
                                maxWidthDiskCache: 600,
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) => const Center(
                                    child: Center(
                                        child: CircularProgressIndicator())),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          )),
                    ),
                  Positioned(
                    bottom: 5.0,
                    right: 8.0,
                    child: InkWell(
                      onTap: () => usersController.updateProfileImage(),
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: MyColor.secondaryColor,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt_rounded,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              color: Colors.grey,
            ),
            minLeadingWidth: 0.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Name",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500)),
                      Obx(() => Text(usersController.userData.value.name ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 13))),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {
                        TextEditingController editingController =
                            TextEditingController(
                                text: usersController.userData.value.name);
                        Get.bottomSheet(
                          StatefulBuilder(
                              builder: (context, setState) => SizedBox(
                                    height: 200,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Enter your name",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          TextFormField(
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            controller: editingController,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLength: 25,
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: const Text("Cancel")),
                                              const SizedBox(width: 20),
                                              TextButton(
                                                  onPressed: editingController
                                                          .text.isEmpty
                                                      ? null
                                                      : () async {
                                                          await UserRepository()
                                                              .userNameUpdate(
                                                                  editingController
                                                                      .text
                                                                      .trim());
                                                          usersController
                                                                  .userData
                                                                  .value
                                                                  .name =
                                                              editingController
                                                                  .text
                                                                  .trim();
                                                          await usersController
                                                              .getMyDetails();
                                                          Get.back();
                                                        },
                                                  child: const Text("Save"))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                          backgroundColor: Colors.white,
                        );
                      },
                      icon:
                          const Icon(Icons.edit, color: MyColor.primaryColor)),
                )
              ],
            ),
            subtitle: const Text(
                "This is not your username or pin. This name will be visible to your Whatsapp contacts.",
                maxLines: 2,
                style: TextStyle(color: Colors.grey, fontSize: 11.0)),
          ),
          sizedBoxH8,
          ListTile(
            leading: const Icon(Icons.error, color: Colors.grey),
            minLeadingWidth: 0.0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("About",
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11.0,
                              fontWeight: FontWeight.w500)),
                      Obx(() => Text(
                          usersController.userData.value.about ?? "No About",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                          ))),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: IconButton(
                      onPressed: () {
                        TextEditingController editingController =
                            TextEditingController(
                                text: usersController.userData.value.about);
                        Get.bottomSheet(
                          StatefulBuilder(
                              builder: (context, setState) => SizedBox(
                                    height: 203,
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "About",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          TextFormField(
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            controller: editingController,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            maxLength: 50,
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: const Text("Cancel")),
                                              const SizedBox(width: 20),
                                              TextButton(
                                                  onPressed: editingController
                                                          .text.isEmpty
                                                      ? null
                                                      : () async {
                                                          await UserRepository()
                                                              .userAboutUpdate(
                                                                  editingController
                                                                      .text
                                                                      .trim());
                                                          usersController
                                                                  .userData
                                                                  .value
                                                                  .about =
                                                              editingController
                                                                  .text
                                                                  .trim();
                                                          await usersController
                                                              .getMyDetails();
                                                          Get.back();
                                                        },
                                                  child: const Text("Save"))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                          backgroundColor: Colors.white,
                        );
                      },
                      icon:
                          const Icon(Icons.edit, color: MyColor.primaryColor)),
                )
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.grey),
            minLeadingWidth: 0.0,
            title: const Text("Phone",
                style: TextStyle(color: Colors.grey, fontSize: 11.0)),
            subtitle: Obx(() =>
                Text(usersController.userData.value.phoneWithDialCode ?? "")),
          )
        ],
      ),
    );
  }
}
