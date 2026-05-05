import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shopapp/utils.dart';


class GetRequest {
  static getRequest(String? url) async {
    String api = '$apiBaseUrl$url';

    print('api--->${api}');

    http.Response response = await http.get(Uri.parse(api));

    log('body-->${response.body}');

    var jsonDecoded = json.decode(response.body);

    if (response.statusCode == 200) {
      return jsonDecoded;
    } else {
      return null;
    }
  }
}
