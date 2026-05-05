import 'package:flutter/material.dart';
import 'package:shopapp/utils.dart';

class AppTextField extends StatefulWidget {
  String? hint;
  TextInputType? textInputType;
  IconData? prefix;
  bool? readOnly;
  TextEditingController? controller;
  bool? obscureText;

  String? validationText;

  Function()? onTap;
  Function()? suffixTap;
  Function(String? val)? onChanged;

  bool validation;
  IconData? suffix;

  AppTextField({
    super.key,
    this.hint,
    this.controller,
    this.suffix,
    this.suffixTap,
    this.textInputType,
    this.validationText,
    this.obscureText = false,
    this.readOnly = false,
    this.validation = false,
    this.onChanged,
    this.onTap,
    this.prefix,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0),
      child: Column(
        children: [
          TextField(
            onTap: () {
              widget.onTap?.call();
            },
            readOnly: widget.readOnly!,

            obscureText: widget.obscureText!,
            onChanged: (widget.onChanged),
            controller: widget.controller,
            keyboardType: widget.textInputType,

            decoration: InputDecoration(
              suffixIcon:
                  widget.suffix == null
                      ? null
                      : InkWell(
                        onTap: () {
                          widget.suffixTap?.call();
                        },
                        child: Icon(widget.suffix!, color: appColor),
                      ),
              errorBorder: OutlineInputBorder(),
              prefixIcon:
                  widget.prefix == null
                      ? null
                      : Icon(widget.prefix!, color: appColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color:
                      widget.validation == true ? Colors.red : Colors.black26,
                  width: widget.validation == true ? 1.5 : 0,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.white,
              filled: true,
              hintText: widget.hint!,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.validation == true ? Colors.red : borderColor,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (widget.validation == true && widget.controller!.text.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "${widget.validationText}",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget validationMessage(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
