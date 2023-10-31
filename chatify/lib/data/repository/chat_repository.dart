import 'package:chatify/const_files/api_names.dart';
import 'package:chatify/services/http_helper.dart';

class ChatRepository {
  final HttpHelper _httpHelper = HttpHelper();

  Future<dynamic> sendMessage(dynamic body) async =>
      await _httpHelper.post(Api.sendMessage, body);

  Future<dynamic> receivedMessageUpdate(dynamic body) async =>
      await _httpHelper.put(Api.receivedMessageUpdate, body);

  Future<dynamic> openedMessageUpdate(dynamic body) async =>
      await _httpHelper.put(Api.openedMessageUpdate, body);

  Future<dynamic> sendChatFile(String imagePath) async {
    var response = await _httpHelper.multipart(
        url: Api.sendChatFile, fieldName: "file", path: imagePath);

    return response;
  }
}
