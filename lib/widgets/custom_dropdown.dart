import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  List<String>? items = [];
  Function(String? data)? onTap;
  String? title;
  bool? filled;

  CustomDropdown({
    super.key,
    this.items,
    this.onTap,
    this.title,
    this.filled = false,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: widget.filled == true ? Colors.white : Colors.transparent,
          border: Border.all(color: Colors.black54),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: DropdownButton(
            isExpanded: true,
            underline: SizedBox.shrink(),
            hint: Text(widget.title ?? 'Select Role'),
            items:
                widget.items!.map(((element) {
                  return DropdownMenuItem(
                    value: element,
                    onTap: () {
                      widget.onTap?.call(element);

                      setState(() {});
                    },
                    child: Text(element),
                  );
                })).toList(),
            onChanged: (_) {},
          ),
        ),
      ),
    );
  }
}
