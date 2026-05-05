import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils.dart';

class DialogContainer extends StatefulWidget {
  Widget? child;

  DialogContainer({super.key, this.child});

  @override
  State<DialogContainer> createState() => _DialogContainerState();
}

class _DialogContainerState extends State<DialogContainer> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black26),
                  color: Colors.white,
                  gradient: LinearGradient(
                    colors: [
                      appColor.withOpacity(.1),
                      Colors.white.withOpacity(.1),
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                width: double.infinity,
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
