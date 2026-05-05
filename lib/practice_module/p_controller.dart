import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'p_widgets.dart';

class PController extends GetxController {
  List<PWidgets> pWidget = [];

  List<TextEditingController> nameCont = [];
  List<TextEditingController> classCont = [];
  List<TextEditingController> phoneCont = [];

  List<List<XFile>> data = [];

  addPhotos(int index) async {
    final image = await ImagePicker().pickMultiImage();
    if (image != null) {
      data[index] = image;
    }
  }

  List<String> images = [];

  galleryImage(int index) async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      images[index] = image.path;
    }
    update();
  }

  addCards() {
    pWidget.add(PWidgets());
    nameCont.add(TextEditingController());
    classCont.add(TextEditingController());
    phoneCont.add(TextEditingController());
    images.add("");
    update();
  }
}
