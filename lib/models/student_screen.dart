import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shopapp/controllers/student_controller.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  StudentController studentController = Get.put(StudentController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    studentController.getAllStudents();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: studentController,
      builder: (cont) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CupertinoTextField(
                      onChanged: (val) {
                        cont.searchApi(val);
                      },
                    ),
                  ),

                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cont.students.length,
                    itemBuilder: (context, index) {
                      final data = cont.students[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.white,

                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(),
                                SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data.name!),
                                      SizedBox(height: 4),
                                      Text(data.cast!),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
