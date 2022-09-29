import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<Map<String, dynamic>> requestCenterData() async {
    Map<String, dynamic> dataConvertedToJSON = {};

    var url = 'https://api.odcloud.kr/api/15077586/v1/centers?page=1&perPage=300';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "Infuser 9fVBilb5dCRuro8bbduZX8+9m11eXNQ/6vRJu8aacsp9Cdyg2+nynid86DctiMQME7JOTWs1evJRFEKywsNqpA=="});
    if (response.statusCode == 200) {
      print('response.body : ${response.body}');
      dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['data'];
      print('result.length : ${result.length}');
    }
    return dataConvertedToJSON;
  }
}