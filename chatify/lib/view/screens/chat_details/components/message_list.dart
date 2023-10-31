import 'dart:developer';

import 'package:chatify/const_files/my_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/controller/chat_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/data/db_models/db_message_model.dart';
import 'package:chatify/view/screens/chat_details/widgets/message_tile/message_tile.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';

class MessageList extends StatefulWidget {
  const MessageList({
    Key? key,
    required this.userId,
    required this.userController,
    required this.chatController,
  }) : super(key: key);

  final String userId;
  final UsersController userController;
  final ChatController chatController;

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: Hive.box<DbMessageModel>(DbNames.message).listenable(),
        builder:
            (BuildContext context, Box<DbMessageModel> value, Widget? child) {
          List<DbMessageModel> fromCurrentUser = value.values
              .where((c) =>
                  c.to.contains(widget.userId) &&
                  c.from.contains(widget.userController.userId))
              .toList();

          List<DbMessageModel> fromThisUser = value.values
              .where((c) =>
                  c.to.contains(widget.userController.userId) &&
                  c.from.contains(widget.userId))
              .toList();

          List<DbMessageModel> data = [...fromCurrentUser, ...fromThisUser];

          data.sort((a, b) => a.createdAt.compareTo(b.createdAt));

          return data.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset("assets/empty.json"),
                    const Text(
                      "No messages yet",
                      style: TextStyle(color: Colors.grey),
                    )
                  ],
                ))
              : ListView.separated(
                  reverse: true,
                  cacheExtent: 1000,
                  itemCount: data.length,
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 4.0, top: 8.0, bottom: 8.0),
                  itemBuilder: (BuildContext context, int index) {
                    int newIndex = data.length - 1 - index;

                    DbMessageModel message = data[newIndex];

                    if (message.from == widget.userId &&
                        message.openedAt == null) {
                      widget.chatController
                          .openedMessageUpdate(message.id, message.from);
                    }

                    return Slidable(
                      key: Key(message.id),
                      closeOnScroll: true,
                      endActionPane: message.from == widget.userId
                          ? null
                          : ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.15,
                              children: [
                                SlidableAction(
                                  padding: EdgeInsets.zero,
                                  spacing: 0,
                                  onPressed: (context) {
                                    Box<DbMessageModel> messageBox =
                                        Hive.box<DbMessageModel>(
                                            DbNames.message);
                                    messageBox.delete(message.id);
                                  },
                                  foregroundColor: MyColor.primaryColor,
                                  backgroundColor: Colors.transparent,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),
                      startActionPane: message.from != widget.userId
                          ? null
                          : ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.15,
                              children: [
                                SlidableAction(
                                  padding: EdgeInsets.zero,
                                  spacing: 0,
                                  onPressed: (context) {
                                    Box<DbMessageModel> messageBox =
                                        Hive.box<DbMessageModel>(
                                            DbNames.message);
                                    messageBox.delete(message.id);
                                  },
                                  foregroundColor: MyColor.primaryColor,
                                  backgroundColor: Colors.transparent,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),
                      child: MessageTile(
                        messageModel: message,
                        messageText: message.message,
                        myMessage: message.from == widget.userId ? false : true,
                        send: true,
                        messageType: message.messageType ?? "text",
                        filePath: message.filePath,
                        received: message.receivedAt == null ? false : true,
                        opened: message.openedAt == null ? false : true,
                        index: index,
                        dateTime: message.from == widget.userId
                            ? message.receivedAt ?? DateTime.now()
                            : message.createdAt,
                        chatController: widget.chatController,
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 6.0),
                );
        },
      ),
    );
  }
}
