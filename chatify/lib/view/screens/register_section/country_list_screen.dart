import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatify/const_files/my_color.dart';
import 'package:chatify/controller/register_controller.dart';
import 'package:chatify/data/model/county_model.dart';
import 'package:chatify/view/widgets/common_appbar.dart';
import 'package:chatify/view/widgets/common_scaffold.dart';
import 'package:chatify/view/widgets/sizedBox.dart';

class CountryListScreen extends StatelessWidget {
  const CountryListScreen({Key? key}) : super(key: key);

  static RegisterController registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      commonHorizontalPadding: false,
      appBar: const CommonAppBar(
        automaticallyImplyLeading: true,
        title: "Choose a country",
        backgroundColor: MyColor.primaryColor,
      ),
      backgroundColor: MyColor.primaryColor,
      body: ListView.separated(
        itemCount: RegisterController.countryModel.data.length,
        itemBuilder: (BuildContext context, int index) {
          Datum data = RegisterController.countryModel.data[index];

          return Obx(
            () => ListTile(
              leading: Text(data.flag),
              title: Text(
                data.name,
                style: TextStyle(
                    color: data.name ==
                            registerController.selectedCountry.value.name
                        ? MyColor.secondaryColor
                        : Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.dialCode,
                    style: const TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  sizedBoxW8,
                  if (data.name ==
                      registerController.selectedCountry.value.name)
                    const Icon(Icons.check, color: MyColor.buttonColor)
                  else
                    const SizedBox(width: 24.0)
                ],
              ),
              onTap: () => registerController.changeCountry(data),
              minLeadingWidth: 0.0,
              contentPadding: const EdgeInsets.only(left: 16.0, right: 8.0),
              dense: true,
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
