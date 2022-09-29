import 'package:flutter/cupertino.dart';
import 'package:flutter_project/model/centerDataRes.dart';

import '../network/apiService.dart';

enum LoadingStatus {none, completed, loading}

class MapPageViewModel extends ChangeNotifier {
  LoadingStatus loadingStatus = LoadingStatus.none;
  List<CenterData>? centerDataList;

  void requestCenterData() async {
    loadingStatus = LoadingStatus.loading;
    var response = await ApiService().requestCenterData();
    if (response.isNotEmpty) {
      centerDataList = CenterDataRes.fromJson(response).data;
      loadingStatus = LoadingStatus.completed;
      notifyListeners();
    }
  }
}
