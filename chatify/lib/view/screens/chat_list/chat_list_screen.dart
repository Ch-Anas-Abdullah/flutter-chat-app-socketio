import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/data/db_models/db_message_model.dart';
import 'package:chatify/data/db_models/db_pending_message_model.dart';
import 'package:chatify/view/widgets/image_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/data/db_models/db_chat_list_model.dart';
import 'package:chatify/view/screens/contact_section/contact_list_screen.dart';
import 'package:chatify/view/widgets/no_user_image.dart';
import 'package:chatify/view/widgets/sizedBox.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  static ChatController chatController = Get.put(ChatController());
  static UsersController userController = Get.put(UsersController());

  @override
  Widget build(BuildContext context) {
    userController.getChatList();
    return Scaffold(
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
          title: Obx(
            () => RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Welcome back, ",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  TextSpan(
                    text: userController.userData.value.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )
                ],
                style: const TextStyle(color: Colors.white, letterSpacing: 1),
              ),
              textAlign: TextAlign.center,
            ),
          )),
      body: Obx(
        () => userController.chatListData.isEmpty
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/empty.json"),
                  const Text(
                    "No chats yet",
                    style: TextStyle(color: Colors.grey),
                  )
                ],
              ))
            : ListView.separated(
                separatorBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    color: Colors.grey.shade200,
                  ),
                ),
                itemCount: userController.chatListData.length,
                padding: const EdgeInsets.only(
                    left: 8.0, right: 4.0, top: 8.0, bottom: 50),
                itemBuilder: (BuildContext context, int index) {
                  DbChatListModel userChat = userController.chatListData[index];

                  userController.updateProfileById(userChat.userId);

                  String date =
                      chatController.timerConverter(userChat.createdAt);

                  List<String> userNameImage =
                      userController.getUserNameImage(userChat.userId);

                  return Slidable(
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      extentRatio: 0.2,
                      children: [
                        SlidableAction(
                          padding: EdgeInsets.zero,
                          spacing: 0,
                          onPressed: (context) {
                            Box<DbChatListModel> chatList =
                                Hive.box<DbChatListModel>(DbNames.chatList);
                            chatList.delete(userChat.userId);
                            userController.getChatList();
                          },
                          foregroundColor: MyColor.primaryColor,
                          backgroundColor: Colors.transparent,
                          icon: Icons.delete,
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () {
                        chatController.navigateToChatDetailsScreen(
                            userChat.userId,
                            userNameImage[0],
                            userNameImage[1],
                            userController);
                      },
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userNameImage[0],
                                style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            sizedBoxW4,
                            Text(
                              date,
                              style: TextStyle(
                                  fontSize: 11.0,
                                  color: userChat.unreadCount == 0
                                      ? Colors.grey
                                      : MyColor.secondaryColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          if (userChat.tickCount != 0)
                            if (userChat.tickCount == 3)
                              const Icon(Icons.done_all,
                                  size: 14.0, color: Colors.blue)
                            else if (userChat.tickCount == 2)
                              const Icon(Icons.done_all, size: 14.0)
                            else
                              const Icon(Icons.check, size: 14.0),
                          if (userChat.tickCount != 0) sizedBoxW4,
                          Expanded(
                            child: Text(
                              userChat.message,
                              style: const TextStyle(
                                  fontSize: 13.0, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          sizedBoxW4,
                          if (userChat.unreadCount != 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 3.0, vertical: 3.0),
                              decoration: const BoxDecoration(
                                  color: MyColor.secondaryColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16.0))),
                              alignment: Alignment.center,
                              constraints: const BoxConstraints(
                                  minHeight: 22, minWidth: 22),
                              child: Text(
                                userChat.unreadCount.toString(),
                                style: const TextStyle(
                                    fontSize: 11.0, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      leading: userNameImage[1].isEmpty
                          ? const NoUserImage()
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(150),
                              child: GestureDetector(
                                onTap: () => Get.to(
                                    FullImageScreen(image: userNameImage[1])),
                                child: CachedNetworkImage(
                                  height: 55,
                                  width: 55,
                                  fit: BoxFit.cover,
                                  imageUrl: userNameImage[1],
                                  memCacheHeight: 400,
                                  memCacheWidth: 400,
                                  maxHeightDiskCache: 400,
                                  maxWidthDiskCache: 400,
                                  useOldImageOnUrlChange: true,
                                  placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              )),
                      minLeadingWidth: 0.0,
                      minVerticalPadding: 0.0,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: InkWell(
        onTap: () => Get.to(() => const ContactListScreen()),
        child: Container(
          height: 52.0,
          width: 52.0,
          decoration: const BoxDecoration(
              color: MyColor.buttonColor, shape: BoxShape.circle),
          child: const Icon(
            Icons.message,
            color: Colors.white,
            size: 22.0,
          ),
        ),
      ),
    );
  }
}
