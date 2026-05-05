import 'package:flutter/material.dart';
import 'package:shopapp/widgets/app_text_field.dart';

class ExpandedScreen extends StatefulWidget {
  const ExpandedScreen({super.key});

  @override
  State<ExpandedScreen> createState() => _ExpandedScreenState();
}

class _ExpandedScreenState extends State<ExpandedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: SingleChildScrollView(child: Column(children: []))),
            AppTextField(hint: 'Type'),
          ],
        ),
      ),
    );
  }
}
