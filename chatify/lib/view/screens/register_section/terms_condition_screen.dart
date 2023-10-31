import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/view/screens/register_section/phone_enter_screen.dart';
import 'package:chatify/view/widgets/sizedBox.dart';

class TermsConditionScreen extends StatelessWidget {
  const TermsConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MyColor.primaryColor,
      body: SizedBox(
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
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Text(
                    "ChatBuddy",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold),
                  ),
                  SvgPicture.asset("assets/boarding.svg"),
                  const Column(
                    children: [
                      Text(
                        "Stay connected with your friends and family",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold),
                      ),
                      sizedBoxH16,
                      Row(
                        children: [
                          Icon(Icons.security,
                              color: Colors.lightGreen, size: 22.0),
                          sizedBoxW8,
                          Text(
                            "Secure, private messaging",
                            style:
                                TextStyle(color: Colors.white, fontSize: 17.0),
                          ),
                        ],
                      )
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => Get.offAll(() => const PhoneEnterScreen()),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => MyColor.buttonColor),
                      padding: MaterialStateProperty.resolveWith((states) =>
                          const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 72.0)),
                    ),
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
