import 'package:flutter/material.dart';
import 'package:shopapp/utils.dart';

class AppButton extends StatefulWidget {
  double? height;
  double? width;

  Color? color;
  String? txt;
  Function()? onTap;

  AppButton({
    super.key,
    this.width = double.infinity,
    this.height = 48,
    this.txt,
    this.onTap,
    this.color,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: (widget.onTap),
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
              colors:
                  widget.color != null
                      ? [widget.color!, widget.color!.withOpacity(.7)]
                      : [appColor, appColor.withOpacity(.7)],
            ),
          ),
          child: Center(
            child: Text(
              widget.txt!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
