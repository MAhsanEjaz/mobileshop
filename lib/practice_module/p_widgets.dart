import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shopapp/practice_module/p_controller.dart';
import 'package:shopapp/widgets/app_text_field.dart';

class PWidgets extends StatefulWidget {
  int? index;

  PWidgets({super.key, this.index});

  @override
  State<PWidgets> createState() => _PWidgetsState();
}

class _PWidgetsState extends State<PWidgets> {
  PController p = Get.put(PController());

  @override
  Widget build(BuildContext context) {
    final myIndex = widget.index!;

    return GetBuilder(
      init: p,
      builder: (cont) {
        return Card(
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  cont.galleryImage(myIndex);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                  ),
                  height: 100,
                  width: 100,
                  child: Icon(Icons.image),
                ),
              ),
              Image.file(File(cont.images[myIndex])),
              SizedBox(height: 10),
              AppTextField(
                hint: "Student Name",
                controller: cont.nameCont[myIndex],
              ),
              AppTextField(hint: "Class", controller: cont.classCont[myIndex]),
              AppTextField(hint: "Phone", controller: cont.phoneCont[myIndex]),
            ],
          ),
        );
      },
    );
  }
}
