import 'dart:developer';

import 'package:chatify/const_files/db_names.dart';
import 'package:chatify/const_files/keys/server_keys.dart';
import 'package:chatify/controller/socket_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/data/db_models/db_user_model.dart';
import 'package:chatify/view/widgets/no_user_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class CallListScreen extends StatelessWidget {
  const CallListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Call")),
    );
  }
}

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  SocketController controller = Get.put(SocketController());
  UsersController usersController = Get.put(UsersController());
  @override
  void initState() {
    super.initState();
    // Set up event listeners for call:incoming and call:accepted events
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Calls')),
      body: const Center(child: Text('This Module is in progress 💻')
          //      Obx(
          //   () => controller.isCallOutgoing.value
          //       ? Center(
          //           child: OutgoingCallScreen(
          //             controller: controller,
          //           ),
          //         )
          //       : controller.isCallIncoming.value
          //           ? _buildIncomingCallWidget()
          //           : ValueListenableBuilder(
          //               valueListenable:
          //                   Hive.box<DbUserModel>(DbNames.user).listenable(),
          //               builder: (BuildContext context, Box<DbUserModel> value,
          //                   Widget? child) {
          //                 List<DbUserModel> data = value.values
          //                     .where((element) =>
          //                         element.id != usersController.userId.value)
          //                     .toList();
          //                 data.sort((a, b) => a.name.compareTo(b.name));

          //                 usersController.usersCount.value = data.length;

          //                 return ListView.builder(
          //                   itemCount: data.length,
          //                   padding: const EdgeInsets.only(top: 8.0),
          //                   itemBuilder: (BuildContext context, int index) {
          //                     DbUserModel userData = data[index];
          //                     return ListTile(
          //                       onTap: () {
          //                         log("Calling to:  ${userData.id}");
          //                         controller.socket
          //                             .emit('call:initiate', userData.id);
          //                         controller.isCallOutgoing.value = true;
          //                       },
          //                       title: Text(userData.name),
          //                       leading: userData.imagePath.isEmpty
          //                           ? const NoUserImage()
          //                           : CircleAvatar(
          //                               backgroundImage:
          //                                   NetworkImage(userData.imagePath),
          //                               radius: 23.0),
          //                     );
          //                   },
          //                 );
          //               },
          //             ),

          //   // ElevatedButton(
          //   //     onPressed: () {
          //   //       controller.socket.emit('call:initiate', 'callee-id');
          //   //     },
          //   //     child: const Text('Initiate Call'),
          //   //   ),
          // )
          ),
    );
  }

  Widget _buildIncomingCallWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Incoming call from ${controller.callerId.value}'),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: _acceptCall,
              child: const Text('Accept'),
            ),
            const SizedBox(width: 20),
            TextButton(
              onPressed: _declineCall,
              child: const Text('Decline'),
            ),
          ],
        ),
      ],
    );
  }

  void _acceptCall() {
    // Send a signal to the server that the call is accepted
    controller.socket.emit('call:accept', controller.callerId.value);
    // Handle logic to start audio streaming and switch to the call screen
  }

  void _declineCall() {
    // Send a signal to the server that the call is declined
    controller.socket.emit('call:decline', controller.callerId.value);
    controller.callerId.value = "";
    controller.isCallIncoming.value = false;
  }

  // @override
  // void dispose() {
  //   socket.disconnect();
  //   super.dispose();
  // }
}

class OutgoingCallScreen extends StatelessWidget {
  final SocketController controller;
  const OutgoingCallScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outgoing Call'),
        backgroundColor: Colors.green, // Customize the color as needed
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'John Doe', // Display the name of the person you're calling
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Calling...', // Show the call status
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.isCallOutgoing.value = false;
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red, // Customize the color as needed
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(
                  Icons.call_end,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
