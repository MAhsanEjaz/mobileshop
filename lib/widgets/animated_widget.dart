import 'package:flutter/material.dart';
import '../utils.dart';

class CustomAnimatedCard extends StatefulWidget {
  Widget? child;

  CustomAnimatedCard({super.key, this.child});

  @override
  State<CustomAnimatedCard> createState() => _CustomAnimatedCardState();
}

class _CustomAnimatedCardState extends State<CustomAnimatedCard>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            appColor.withOpacity(.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),

      duration: Duration(microseconds: 50000),
      child: widget.child,
    );
  }
}
