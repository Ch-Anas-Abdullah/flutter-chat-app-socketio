import 'package:chatify/view/screens/call_section/call_list_screen.dart';
import 'package:chatify/view/screens/contact_section/contact_list_screen.dart';
import 'package:chatify/view/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/socket_controller.dart';
import 'package:chatify/controller/users_controller.dart';
import 'package:chatify/view/screens/chat_list/chat_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static SocketController socketController =
      Get.put(SocketController(), permanent: true);
  UsersController userController = Get.put(UsersController());

  double customWidth = (Get.width - 20) / 5;
  double customHeight = 40;
  List pages = [
    const ChatListScreen(),
    const ProfileScreen(),
    const CallScreen()
  ];
  int currentIndex = 0;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    socketController.connectToSocket();

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      userController.updateUserStatus(true, '');
    } else {
      userController.updateUserStatus(false, '');
    }

    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Theme(
        data: ThemeData(useMaterial3: false),
        child: BottomAppBar(
          color: MyColor.primaryColor,
          height: 60,
          // shape: AutomaticNotchedShape(
          //   RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(
          //       top: const Radius.circular(20),
          //     ),
          //   ),

          // ),
          shape: const CircularNotchedRectangle(),

          notchMargin: 7,

          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  icon: Icon(
                    Icons.chat,
                    color: currentIndex == 0
                        ? MyColor.secondaryColor
                        : Colors.white,
                  ),
                  onPressed: () {
                    _onTabSelected(0);
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.call,
                  color:
                      currentIndex == 2 ? MyColor.secondaryColor : Colors.white,
                ),
                onPressed: () {
                  _onTabSelected(2);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color:
                      currentIndex == 1 ? MyColor.secondaryColor : Colors.white,
                ),
                onPressed: () {
                  _onTabSelected(1);
                },
              ),

              const SizedBox(width: 20), // To leave space for the FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
          backgroundColor: MyColor.secondaryColor,
          onPressed: () {
            showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                useSafeArea: true,
                builder: ((context) => const ContactListScreen()));
          },
          child: const Icon(
            Icons.add,
            size: 33,
          )),
      body: pages[currentIndex],
    );
  }

  void _onTabSelected(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
