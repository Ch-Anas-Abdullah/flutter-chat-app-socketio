// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:chatify/const_files/keys/server_keys.dart';
import 'package:chatify/const_files/keys/shared_pref_keys.dart';
import 'package:chatify/services/shared_pref.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/controller/socket_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/data/db_models/db_chat_list_model.dart';
import 'package:chatify/data/db_models/db_message_model.dart';
import 'package:chatify/data/db_models/db_pending_message_model.dart';
import 'package:chatify/data/model/message/messageModel.dart';
import 'package:chatify/data/repository/chat_repository.dart';
import 'package:chatify/data/repository/user_repository.dart';
import 'package:chatify/utility/utility.dart';
import 'package:chatify/view/screens/chat_details/chat_details_screen.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class ChatController extends GetxController {
  SocketController socketController = Get.put(SocketController());
  UsersController userController = Get.put(UsersController());
  RxBool showEmojiPicker = false.obs;
  FocusNode focusNode = FocusNode();
  UserRepository userRepository = UserRepository();
  ChatRepository chatRepository = ChatRepository();
  RxList downloadingFile = [].obs;
  String userID = "";
  Box<DbMessageModel> messageBox = Hive.box<DbMessageModel>(DbNames.message);
  Box<DbPendingMessageModel> pendingMessageBox =
      Hive.box<DbPendingMessageModel>(DbNames.pendingMessage);
  Box chatListBox = Hive.box<DbChatListModel>(DbNames.chatList);
  List<DbMessageModel> data = <DbMessageModel>[].obs;
  RxBool userStatus = false.obs;
  RxString typing = ''.obs;
  String currentlyPlayingAudio = "";
  Duration position = Duration.zero;
  Rx<TextEditingController> messageTextField = TextEditingController().obs;

  void navigateToChatDetailsScreen(
      String id, String name, String? user, UsersController userController) {
    setUnreadMessageToZero(id);
    checkUserStatus(id);

    messageTextField.value.text = "";
    messageTextField.value.clear();

    Get.to(() => ChatScreen(
          userId: id,
          userName: name,
          userImage: user ?? "",
          homeInstance: userController,
        ));
  }

  void setUnreadMessageToZero(String userId) {
    DbChatListModel? chatData = chatListBox.get(userId);

    if (chatData != null) {
      chatData.unreadCount = 0;
      chatListBox.put(userId, chatData);
    }

    userController.getChatList();
  }

  Future<void> checkUserStatus(String id) async {
    var result = await userRepository.getUserStatus(id);

    try {
      if (result.runtimeType.toString() == 'Response') {
        var data = jsonDecode(result.body);
        userStatus.value = data["status"] ?? false;
        typing.value = data["typing"] ?? false;
      } else {
        Utility.httpResponseValidation(result);
      }
    } catch (e) {
      Utility().customDebugPrint("error usersList $e");
    }

    try {
      String eventString = '/user_status$id';

      socketController.socket.on(eventString, (data) {
        userStatus.value = bool.tryParse(data['status'].toString()) ?? false;
        typing.value = data["typing"].toString();
      });
    } catch (e) {
      Utility().customDebugPrint("status socket error $e");
    }
  }

  Future<void> sendMessage(String userId) async {
    userController.updateUserStatus(true, "");
    if (messageTextField.value.text.trim().isEmpty) {
      sendVoice();
    } else {
      sendTextMessage(userId);
    }
  }

  Future<void> pickImageFile(String userId) async {
    await Permission.storage.request();
    var image = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (image != null && image.files.first.path != null) {
      log(image.files.first.path.toString());
      sendChatFile(userId, image.files.first.path.toString(), "IMAGE", "image");
    }
  }

  /// This method is used to send the files to the server
  ///
  /// The [userId] must be non-null
  ///
  /// The [path] must be non-null, it should be a valid path of file
  ///
  /// The [messageText] is nullable, if its null default message text is media type (image, video, audio, and document)

  Future<void> sendChatFile(String userId, String path, String messageText,
      String messageType) async {
    var res = await saveFile(path.toString(), subDirectoryName: ".sent");
    if (res["isSuccess"].toString() == "true") {
      path = res["filePath"].split("file://").last;
      log(path.toString());
      String messageId =
          "${userController.userId.value}$userId${DateTime.now().microsecondsSinceEpoch}";

      DateTime currentDate = DateTime.now();
      addToMessageDb(messageId, messageText, userId, messageType, currentDate,
          filePath: path);

      addToPendingDb(messageId);
      addToChatListDb(messageId, messageText, userId, messageType, currentDate,
          filePath: path);
      var result = await chatRepository.sendChatFile(path);
      if (result.runtimeType.toString() == "Response") {
        var response = jsonDecode(result.body);

        if (response['status']) {
          addToServer(messageId, messageText, userId, messageType, currentDate,
              filePath: response['fileName']);
        }
      }
    } else {
      Fluttertoast.showToast(
          msg: res["errorMessage"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black.withOpacity(.6),
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  Future<void> sendVoice() async {}

  Future<void> sendTextMessage(String userId) async {
    //unique message id generation by from user and to user id with current time microsecondsSinceEpoch
    String messageId =
        "${userController.userId.value}$userId${DateTime.now().microsecondsSinceEpoch}";

    String messageText = messageTextField.value.text;
    messageTextField.value.clear();
    messageTextField.update((val) {});

    DateTime currentDate = DateTime.now();

    addToMessageDb(messageId, messageText, userId, "text", currentDate);

    addToPendingDb(messageId);

    addToChatListDb(messageId, messageText, userId, "text", currentDate);

    addToServer(messageId, messageText, userId, "text", currentDate);
  }

  void addToMessageDb(String messageId, String messageText, String userId,
      String messageType, DateTime currentDate,
      {String? filePath}) {
    log(filePath.toString());
    DbMessageModel data = DbMessageModel(
      id: messageId,
      message: messageText,
      from: userController.userId.value,
      to: userId,
      createdAt: currentDate,
      receivedAt: null,
      openedAt: null,
      filePath: filePath ?? "",
      fileLocalPath: filePath ?? "",
      messageType: messageType,
    );
    messageBox.put(messageId, data);
  }

  void addToPendingDb(String messageId) {
    DbPendingMessageModel pendingMessageModel =
        DbPendingMessageModel(messageId);

    pendingMessageBox.put(messageId, pendingMessageModel);
  }

  void addToChatListDb(String messageId, String messageText, String userId,
      String messageType, DateTime currentDate,
      {String? filePath}) {
    DbChatListModel dbChatListModel = DbChatListModel(
        message: messageText,
        createdAt: currentDate,
        messageId: messageId,
        userId: userId,
        unreadCount: 0,
        filePath: filePath ?? "",
        messageType: messageType,
        tickCount: 1);

    chatListBox.put(userId, dbChatListModel);
  }

  Future<void> addToServer(String messageId, String messageText, String userId,
      String messageType, DateTime currentDate,
      {String? filePath}) async {
    MessageModel body = MessageModel(
      id: messageId,
      message: messageText,
      from: userController.userId.value,
      to: userId,
      createdAt: currentDate,
      filePath: filePath ?? "",
      messageType: messageType,
    );

    var response = await chatRepository.sendMessage(body.toMap());

    if (response.runtimeType.toString() == "Response") {
      pendingMessageBox.delete(messageId);
    }
  }

  void openedMessageUpdate(String id, String fromId) {
    DateTime currentDate = DateTime.now();

    chatRepository.openedMessageUpdate({
      "id": id,
      "openedAt": currentDate.toIso8601String(),
      "fromId": fromId
    });

    DbMessageModel? messageData = messageBox.get(id);

    messageData?.openedAt = currentDate;

    messageBox.put(id, messageData!);
    DbChatListModel? chatListData = chatListBox.get(userID);
    chatListData?.unreadCount = 0;
    chatListBox.put(userID, chatListData!);
  }

  Future<void> pendingMessageCheck() async {
    List<DbPendingMessageModel> pendingData = pendingMessageBox.values.toList();

    for (var element in pendingData) {
      DbMessageModel? messageData = messageBox.get(element.messageId);

      MessageModel body = MessageModel(
        id: messageData!.id,
        message: messageData.message.isEmpty ? " " : messageData.message,
        from: messageData.from,
        to: messageData.to,
        createdAt: messageData.createdAt,
        messageType: "text",
      );

      var response = await chatRepository.sendMessage(body.toMap());

      if (response.runtimeType.toString() == "Response") {
        pendingMessageBox.delete(messageData.id);
      }
    }
  }

  @override
  void onInit() {
    messageTextField.value.text = "";
    messageTextField.value.clear();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmojiPicker.value = false;
        update();
      }
    });
    super.onInit();
  }

  @override
  void dispose() {
    messageTextField.value.dispose();
    super.dispose();
  }

  String timerConverter(DateTime date) {
    int currentDay = DateTime.now().day;
    int previousDay = DateTime.now().subtract(const Duration(days: 1)).day;

    int customDay = date.day;
    int customPreviousDay = date.subtract(const Duration(days: 1)).day;

    if (customDay == currentDay) {
      return DateFormat("hh:mm a").format(date);
    } else if (previousDay == customPreviousDay) {
      return "Yesterday";
    } else {
      return DateFormat("dd/MM/yy").format(date);
    }
  }

  Future saveFileToDirectory(DbMessageModel messageModel) async {
    var url = "${ServerKeys.baseurl}chatFiles/${messageModel.filePath!}";
    try {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
      downloadingFile.add(messageModel.id);
      String authToken =
          await SharedPref().readString(SharedPrefKeys.authToken);
      final http.Response response = await http.get(Uri.parse(url), headers: {
        HttpHeaders.acceptHeader: "application/json",
        HttpHeaders.authorizationHeader: "Bearer $authToken"
      });
      if (response.statusCode == 200) {
        Directory? appDocumentsDirectory =
            await getApplicationDocumentsDirectory();
        log(appDocumentsDirectory.toString());

        await Directory(appDocumentsDirectory.absolute.path)
            .create(recursive: true);
        String filePath =
            "${appDocumentsDirectory.absolute.path}/${path.basename(url)}";
        File file = File(filePath);
        await file.writeAsBytes(
          response.bodyBytes,
        );
        var res = await saveFile(filePath);
        if (res["isSuccess"].toString() == "true") {
          var path = res["filePath"].split("file://").last;
          Box messageBox = Hive.box<DbMessageModel>(DbNames.message);
          DbMessageModel messageData = messageBox.get(messageModel.id);
          messageData.fileLocalPath = path;
          await messageBox.put(messageData.id, messageData);
          log("downloaded");
        }
        await file.delete();
      } else {}
      downloadingFile.remove(messageModel.id);
    } catch (e) {
      print(e.toString());
      downloadingFile.remove(messageModel.id);
    }
  }
}

Future moveFile(String sourceFilePath, String destinationFilePath) async {
  try {
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
    File sourceFile = File(sourceFilePath);
    if (await sourceFile.exists()) {
      Directory destinationDir = Directory(destinationFilePath);

      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
      }

      File destinationFile =
          File('$destinationFilePath/${sourceFile.path.split('/').last}');

      await sourceFile.copy(destinationFile.path);

      return destinationFile.path;
    } else {
      print('Source file does not exist.');
    }
  } catch (e) {
    print('Error while moving the file: $e');
  }
}

const MethodChannel _channel = MethodChannel("com.example.Chatify/FileSaver");
Future saveFile(String file,
    {String? name, String subDirectoryName = ""}) async {
  if (subDirectoryName.isNotEmpty) {
    subDirectoryName = "/$subDirectoryName";
  }
  final result =
      await _channel.invokeMethod("saveFileToGallery", <String, dynamic>{
    "file": file,
    "name": name,
    "subDir": subDirectoryName,
  });
  log(result.toString());
  return result;
}

// class AudioDataModel {
//   final String filePath;
//   final String title;
//   late AudioPlayer audioPlayer;

//   AudioDataModel(
//       {required this.filePath, required this.title}){
//           audioPlayer = AudioPlayer().setFilePath(filePath);
//       };
// }
