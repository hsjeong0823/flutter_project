class CenterDataRes {
  final List<CenterData> data;

  CenterDataRes({required this.data});

  factory CenterDataRes.fromJson(Map<String, dynamic> parsedJson){
    var list = parsedJson['data'] as List;
    List<CenterData> imagesList = list.map((i) => CenterData.fromJson(i)).toList();

    return CenterDataRes(
        data: imagesList
    );
  }
}

class CenterData {
  final String id;
  final String address;
  final String sido;
  final String centerName;
  final String lat;
  final String lng;
  final String phoneNumber;

  CenterData({required this.id,
    required this.address,
    required this.sido,
    required this.centerName,
    required this.lat,
    required this.lng,
    required this.phoneNumber});

  factory CenterData.fromJson(Map<String, dynamic> parsedJson){
    return CenterData(
        id: parsedJson['id'].toString(),
        address: parsedJson['address'],
        sido: parsedJson['sido'],
        centerName: parsedJson['centerName'].replaceAll('코로나19', ''),
        lat: parsedJson['lat'],
        lng: parsedJson['lng'],
        phoneNumber: parsedJson['phoneNumber']
    );
  }
}
