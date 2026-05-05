import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopapp/controllers/cash_controller.dart';
import 'package:shopapp/utils.dart';
import 'package:shopapp/widgets/app_button.dart';
import 'package:shopapp/widgets/app_text_field.dart';

import '../controllers/user_controller.dart';
import '../widgets/animated_widget.dart';
import 'nav_bar_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  UserController userController = Get.find();
  CashController cashController = Get.find();

  bool emailValidation = false;
  bool passwordValidation = false;

  bool viewPassword = true;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: userController,
      builder: (cont) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  customHeight(.04),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: responseText(context, .06),
                    ),
                  ),
                  customHeight(.04),
                  AppTextField(
                    validationText: 'Please enter email',
                    validation: emailValidation,
                    prefix: CupertinoIcons.mail_solid,
                    hint: 'Email',
                    controller: emailCont,
                    textInputType: TextInputType.emailAddress,
                  ),
                  AppTextField(
                    validationText: 'Please enter password',
                    validation: passwordValidation,
                    prefix: CupertinoIcons.lock_shield_fill,
                    hint: 'Password',
                    suffix:
                        viewPassword
                            ? Icons.remove_red_eye
                            : Icons.visibility_off,
                    suffixTap: () {
                      viewPassword = !viewPassword;
                      setState(() {});
                    },

                    controller: passwordCont,
                    textInputType: TextInputType.visiblePassword,
                    obscureText: viewPassword,
                  ),

                  customHeight(.01),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder:
                              (context) => Container(
                                width: Get.width,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Text(
                                        'Coming Soon',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        );
                      },

                      child: Text(
                        'Forget Password',
                        style: TextStyle(
                          color: appColor,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  customHeight(.01),

                  cont.loading
                      ? Center(
                        child: SizedBox(
                          height: 35,
                          width: 35,
                          child: CircularProgressIndicator(
                            year2023: false,
                            color: appColor,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                      : GetBuilder(
                        init: cashController,
                        builder: (cash) {
                          return AppButton(
                            txt: 'Sign in',
                            onTap: () {
                              cash.logInApi();
                              Map<String, dynamic> body = {
                                "email": emailCont.text.trim(),
                                "password": passwordCont.text.trim(),
                              };

                              if (validation()) {
                                cont.login(body);
                              }

                              setState(() {});
                            },
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

  bool validation() {
    return FieldValidator.validateFields([
      FieldItem(
        controller: emailCont,
        setError: (value) => emailValidation = value,
      ),
      FieldItem(
        controller: passwordCont,
        setError: (value) => passwordValidation = value,
      ),
    ]);
  }
}

class FieldValidator {
  static bool validateFields(List<FieldItem> fields) {
    bool isValid = true;

    for (var field in fields) {
      if (field.controller.text.trim().isEmpty) {
        field.setError(true);
        isValid = false;
      } else {
        field.setError(false);
      }
    }

    return isValid;
  }
}

class FieldItem {
  final TextEditingController controller;
  final Function(bool) setError;

  FieldItem({required this.controller, required this.setError});
}
