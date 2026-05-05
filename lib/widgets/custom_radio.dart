import 'package:flutter/material.dart';
import 'package:shopapp/utils.dart';

class CustomRadio extends StatefulWidget {
  String? groupValue;
  String? title;
  Function(String? val)? onTap;

  CustomRadio({super.key, this.groupValue, this.title, this.onTap});

  @override
  State<CustomRadio> createState() => _CustomRadioState();
}

class _CustomRadioState extends State<CustomRadio> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio(
            activeColor: appColor,

            value: widget.title,
            groupValue: widget.groupValue,
            onChanged: (val) {
              widget.onTap?.call(val);
            },
          ),
          Text(
            widget.title ?? '',
            style: TextStyle(
              color:
                  widget.groupValue == widget.title ? appColor : Colors.black,
              fontWeight:
                  widget.groupValue == widget.title
                      ? FontWeight.bold
                      : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
