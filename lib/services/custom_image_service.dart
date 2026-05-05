import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shopapp/utils.dart';

class CustomImageService {
  static imageService(
    Map<String, String> field,
    String? imgPath,
    String? url,
  ) async {
    final baseUrl = '$apiBaseUrl$url';
    log('apiUrl-->$baseUrl');

    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

    request.fields.addAll(field);

    request.files.add(await http.MultipartFile.fromPath('image', imgPath!));

    var response = await request.send();

    if (response.statusCode == 200) {
      customSnackBar('Success', 'Shop added', false);
    } else {
      customSnackBar('Failed', 'Something went wrong', true);
    }
  }
}
