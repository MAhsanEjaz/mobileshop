import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopapp/practice_module/p_controller.dart';
import 'package:shopapp/practice_module/p_widgets.dart';

class PScreen extends StatefulWidget {
  const PScreen({super.key});

  @override
  State<PScreen> createState() => _PScreenState();
}

class _PScreenState extends State<PScreen> {
  PController controller = Get.put(PController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      builder: (cont) {
        return Scaffold(

          appBar: AppBar(),
          body: SafeArea(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: cont.pWidget.length,
                  itemBuilder: (context, index) {
                    return PWidgets(index: index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
