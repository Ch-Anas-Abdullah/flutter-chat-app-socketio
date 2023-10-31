import 'dart:convert';
import 'dart:developer';

import 'package:chatify/const_files/api_names.dart';
import 'package:chatify/data/model/user/user_model.dart';
import 'package:chatify/data/model/user/users_list_model.dart';
import 'package:chatify/data/model/user_login_registration_model.dart';
import 'package:chatify/services/http_helper.dart';

class UserRepository {
  final HttpHelper _httpHelper = HttpHelper();

  Future<dynamic> getMyDetails() async {
    var response = await _httpHelper.get(Api.myDetails);

    if (response.runtimeType.toString() == "Response") {
      UserModel userModel = UserModel.fromJson(jsonDecode(response.body));
      return userModel;
    }
    return response;
  }

  Future<dynamic> getUsersList() async {
    var response = await _httpHelper.get(Api.usersList);

    if (response.runtimeType.toString() == "Response") {
      UsersListModel usersListModel =
          UsersListModel.fromMap(jsonDecode(response.body));
      return usersListModel;
    }
    return response;
  }

  Future<dynamic> getUserStatus(String id) async =>
      await _httpHelper.get("${Api.userStatus}/$id");

  Future<dynamic> getUserDetails(String phoneNumber) async {
    var response = await _httpHelper.get(Api.userDetails + phoneNumber);

    if (response.runtimeType.toString() == "Response") {
      UserModel userStatusModel = UserModel.fromJson(jsonDecode(response.body));
      return userStatusModel;
    }
    return response;
  }

  Future<dynamic> getUserDetailsList(List<List<String>> contact) async {
    Map<String, String> body = {};
    for (var i = 0; i < contact.length; i++) {
      body.addAll({
        "phoneNumbers[$i]": "${contact[i][0]}@#%${contact[i][1]}",
      });
    }
    var response =
        await _httpHelper.post(Api.userDetailsList, body, auth: false);

    if (response.runtimeType.toString() == "Response") {
      List<UserModel> userStatusModel = [];
      for (var element in jsonDecode(response.body)) {
        userStatusModel.add(UserModel.fromJson(element));
      }
      log("User Model Length: ${userStatusModel.length}  ${userStatusModel.runtimeType}");
      return userStatusModel;
    }
    return response;
  }

  Future<dynamic> updateUserStatus(bool status, String typing) async =>
      await _httpHelper
          .put(Api.userStatus, {"status": "$status", "typing": typing});

  Future<dynamic> userLoginRegistration(
      String phoneNumber, String dialCode) async {
    var response = await _httpHelper.post(Api.userRegistration,
        {"phoneNumber": phoneNumber, "dialCode": dialCode},
        auth: false);

    if (response.runtimeType.toString() == "Response") {
      UserLoginRegistrationModel userAuth =
          UserLoginRegistrationModel.fromJson(jsonDecode(response.body));
      return userAuth;
    }
    return response;
  }

  Future<dynamic> profileImageUpload(String imagePath) async {
    var response = await _httpHelper.multipart(
        url: Api.profileImage, fieldName: "image", path: imagePath);

    return response;
  }

  Future<dynamic> userNameUpdate(String userName) async {
    var response = await _httpHelper.put(Api.userName, {"name": userName});

    return response;
  }

  Future<dynamic> userAboutUpdate(String about) async {
    var response = await _httpHelper.put(Api.userAbout, {"name": about});

    return response;
  }

  Future<dynamic> getUserDetailsById(String userId) async {
    var response = await _httpHelper.get(Api.userDetailsById + userId);

    if (response.runtimeType.toString() == "Response") {
      UserModel userStatusModel = UserModel.fromJson(jsonDecode(response.body));
      return userStatusModel;
    }
    return response;
  }
}
