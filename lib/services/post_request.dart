import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:shopapp/utils.dart';

class PostRequest {
  static postRequest(String? url, Map? body) async {
    try {
      final baseUrl = '$apiBaseUrl$url';

      var headers = {"Content-Type": "application/json"};

      log('body-->$body');
      log('url-->$baseUrl');

      http.Response response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(body),
        headers: headers,
      );

      log('response-->${response.body}');

      var jsonDecoded = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonDecoded;
      } else {
        return null;
      }
    } catch (err) {
      print(err);
      return false;
    }
  }
}
