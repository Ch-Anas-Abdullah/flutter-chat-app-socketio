import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/register_controller.dart';
import 'package:chatify/view/screens/register_section/country_list_screen.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/common_scaffold.dart';
import 'package:chatify/view/widgets/sizedBox.dart';

class PhoneEnterScreen extends StatelessWidget {
  const PhoneEnterScreen({Key? key}) : super(key: key);

  static RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 70),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text:
                              "ChatBuddy will need to verify your phone number.",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        TextSpan(
                            text: " What's my number?",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                            recognizer: TapGestureRecognizer()..onTap = () {}),
                      ],
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          letterSpacing: 1),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  sizedBoxH32,
                  sizedBoxH32,
                  SizedBox(
                    width: Get.width * 0.7,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => Get.to(() => const CountryListScreen()),
                          child: Row(
                            children: [
                              const Spacer(),
                              Obx(() => Text(
                                    registerController.isInvalidCode.value
                                        ? "Invalid country code"
                                        : registerController
                                            .selectedCountry.value.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        letterSpacing: 1),
                                  )),
                              const Spacer(),
                              const Icon(Icons.arrow_drop_down_sharp,
                                  color: MyColor.buttonColor)
                            ],
                          ),
                        ),
                        const Divider(
                            color: MyColor.buttonColor,
                            height: 5.0,
                            thickness: 1.5),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        '+',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      sizedBoxW8,
                                      Expanded(
                                        child: TextField(
                                          controller:
                                              registerController.dialCode,
                                          onChanged: registerController
                                              .onDialCodeChange,
                                          keyboardType: const TextInputType
                                                  .numberWithOptions(
                                              decimal: false, signed: false),
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          style: const TextStyle(
                                              color: Colors.white),
                                          decoration: const InputDecoration(
                                              hintStyle: TextStyle(
                                                  color: Colors.white),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                      color: MyColor.buttonColor,
                                      height: 10.0,
                                      thickness: 1.5),
                                ],
                              ),
                            ),
                            sizedBoxW8,
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: [
                                  TextField(
                                    controller: registerController.phoneNumber,
                                    keyboardType: TextInputType.phone,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                        hintStyle:
                                            TextStyle(color: Colors.white),
                                        hintText: "Phone number",
                                        border: InputBorder.none),
                                  ),
                                  const Divider(
                                      color: MyColor.buttonColor,
                                      height: 5.0,
                                      thickness: 1.5),
                                ],
                              ),
                            ),
                          ],
                        ),
                        sizedBoxH8,
                        const Text("Carrier charges may apply",
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => registerController.loginTOServer(),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => MyColor.buttonColor),
                      padding: MaterialStateProperty.resolveWith((states) =>
                          const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 72.0)),
                    ),
                    child: const Text(
                      "Continue",
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
