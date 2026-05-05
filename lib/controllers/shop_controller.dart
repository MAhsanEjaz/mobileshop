import 'dart:developer';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopapp/main.dart';
import 'package:shopapp/models/shop_model.dart';
import 'package:shopapp/services/custom_image_service.dart';
import 'package:shopapp/services/get_request.dart';
import 'package:shopapp/utils.dart';

class ShopController extends GetxController {
  List<ShopData> shop = [];

  imagePickFunction(bool gallery) async {
    final imagePick = await ImagePicker().pickImage(
      source: gallery ? ImageSource.gallery : ImageSource.camera,
    );
    if (imagePick != null) {
      return imagePick.path;
    }
  }

  shopAddFunction(Map<String, String> body, String? imgPath) async {
    loader();
    await CustomImageService.imageService(body, imgPath, 'addShop');
    await getShop();
    exitLoader();
  }

  getShop() async {
    loader();
    log('userId-->${loginModelUser!.user!.sId}');
    var res = await GetRequest.getRequest(
      'getShop/${loginModelUser!.user!.sId!}',
    );
    exitLoader();

    if (res['status'] != false) {
      ShopModel shopModel = ShopModel.fromJson(res);
      shop = shopModel.data!;



    }
    update();
  }
}
