import 'package:chatify/const_files/my_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/view/screens/profile/profile_screen.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/no_user_image.dart';

import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UsersController usersController = Get.put(UsersController());
    usersController.getMyDetails();

    return Scaffold(
      appBar: const CommonAppBar(title: "Settings", leadingWhiteColor: true),
      body: ListView(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 8, right: 5, top: 15, bottom: 0),
            child: Obx(() => Hero(
                  tag: "editProfile",
                  child: Material(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()));
                        // Get.to(() => const ProfileScreen());
                      },
                      // minLeadingWidth: 60,
                      // isThreeLine: true,
                      contentPadding: EdgeInsets.zero,
                      leading: (usersController.userData.value.image != null &&
                              usersController.userData.value.image!.isEmpty)
                          ? const NoUserImage(containerSize: 60, iconSize: 35)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: CachedNetworkImage(
                                height: 55,
                                width: 55,
                                fit: BoxFit.cover,
                                imageUrl:
                                    usersController.userData.value.image ??
                                        "no link",
                                useOldImageOnUrlChange: true,
                                placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              )),
                      title: Text(
                        usersController.userData.value.name ?? "",
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 17),
                      ),
                      subtitle: Text(
                        usersController.userData.value.about ?? "No About",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                      trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.qr_code,
                            size: 30,
                            color: MyColor.buttonColor,
                          )),
                    ),
                  ),
                )),
          ),
          const Divider(),
          ListTile(
              leading: const Icon(Icons.key, color: Colors.grey),
              title: const Text("Account",
                  style: TextStyle(
                    fontSize: 15,
                  )),
              subtitle: const Text("Privacy, security, change number",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  )),
              onTap: () {}),
          const ListTile(
            leading: Icon(Icons.chat, color: Colors.grey),
            title: Text("Chats",
                style: TextStyle(
                  fontSize: 15,
                )),
            subtitle: Text("Theme, wallpapers, chat history",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
          ),
          const ListTile(
            leading: Icon(Icons.notifications, color: Colors.grey),
            title: Text("Notifications",
                style: TextStyle(
                  fontSize: 15,
                )),
            subtitle: Text("Message, group & call tones",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
          ),
          const ListTile(
            leading: Icon(
              Icons.sync,
              color: Colors.grey,
            ),
            title: Text("Storage and data",
                style: TextStyle(
                  fontSize: 15,
                )),
            subtitle: Text("Network usage, auto-download",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
          ),
          const ListTile(
            leading: Icon(Icons.help, color: Colors.grey),
            title: Text("Help",
                style: TextStyle(
                  fontSize: 15,
                )),
            subtitle: Text("help center, contact us, privacy policy",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                )),
          ),
          const ListTile(
            leading: Icon(Icons.people, color: Colors.grey),
            title: Text("Invite a friend",
                style: TextStyle(
                  fontSize: 15,
                )),
          ),
        ],
      ),
    );
  }
}
