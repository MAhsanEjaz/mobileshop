import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shopapp/widgets/custom_loader.dart';

// final apiBaseUrl = 'http://192.168.100.187:9000/api/';
// final apiBaseUrl = 'http://108.60.209.39:1001/api/';
final apiBaseUrl = 'http://38.247.129.79:1001/api/';

// const appColor = Color(0xff68c4b0);
const appColor = Color(0xff1e5c51);

const whiteColor = Colors.white;
// const borderColor = Color(0xff79dfc4);
const borderColor = Color(0xff1e5c51);

customHeight(double? height) {
  return SizedBox(height: MediaQuery.sizeOf(Get.context!).height * height!);
}

responseText(BuildContext context, double size) {
  return MediaQuery.sizeOf(context).width * size;
}

String formatTimeAmPm(DateTime now) {
  int hour = now.hour;
  final minute = now.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';

  hour = hour % 12;
  if (hour == 0) hour = 12;

  return '$hour:$minute $period';
}
customDialogInterFace(Widget child) {
  PageRouteBuilder pageRouteBuilder = PageRouteBuilder(
    opaque: false,
    pageBuilder: (_, __, ___) {
      return child;
    },
  );
  Navigator.of(Get.context!).push(pageRouteBuilder);
}

numberFormat(num price) {
  return NumberFormat('#,###').format(price);
}

loader() {
  return showDialog(
    barrierColor: Colors.transparent,
    barrierDismissible: false,

    context: Get.context!,
    builder:
        (context) => AlertDialog(
          backgroundColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomLoader(color: Colors.teal),
              // CircularProgressIndicator(
              //   strokeWidth: 5,
              //   // thickness
              //   color: appColor,
              //   // Material 3 color parameter (latest)
              //   year2023: false,
              //   strokeCap: StrokeCap.round,
              // ), // makes it smooth and rounded
            ],
          ),
        ),
  );
}

exitLoader() {
  return Navigator.pop(Get.context!);
}

customDatePicker() async {
  var date = await showDatePicker(
    builder: (context, child) {
      return Theme(
        data: ThemeData(
          primaryColor: appColor,
          colorScheme: ColorScheme.light(
            primary: appColor, // Header background color
            onPrimary: Colors.white, // Header text color
            // Text color (days, months, etc.)
          ),
        ),

        child: child!,
      );
    },
    context: Get.context!,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );

  return date;
}

dateFormat(String? date) {
  return DateFormat('yyyy-MM-dd').format(DateTime.parse(date!));
}

dateFormatWithName(String? date) {
  return DateFormat('d MMMM, yyyy').format(DateTime.parse(date!));
}

customSnackBar(String? title, String? message, bool error) {
  return Get.snackbar(
    title!,
    message!,
    backgroundColor: error ? Colors.red : Colors.green,
    snackStyle: SnackStyle.FLOATING,
    colorText: Colors.white,
  );
}
