import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_project/ui/listPage.dart';
import 'package:flutter_project/viewmodel/mapPageViewModel.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../model/centerDataRes.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class _MapPageState extends State<MapPage> {
  Location location = new Location();
  bool serviceEnabled = false;
  PermissionStatus? permissionGranted;
  Completer<GoogleMapController> controller = Completer();
  CenterData? centerData;
  Map<MarkerId, Marker> markers = new Map();
  double pinPillPosition = -100;

  @override
  void initState() {
    super.initState();
    currentLocation();

    Provider.of<MapPageViewModel>(context, listen: false).requestCenterData();
  }

  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<MapPageViewModel>(context);
    print('loadingStatus : ${viewModel.loadingStatus}');
    if (viewModel.loadingStatus == LoadingStatus.completed) {
      setMapMarker(viewModel.centerDataList);
    }

    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            getGoogleMap(),
            getBottomInfoView(),
            Padding(padding: EdgeInsets.only(top: 50, left: 10),
              child: ElevatedButton(
                  onPressed: (() {
                    hideBottomView();
                    currentLocation();
                  }),
                  child: Icon(Icons.my_location_outlined),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child:  Padding(padding: EdgeInsets.only(top: 50, right: 10),
                child: ElevatedButton(
                    onPressed: (() {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ListPage(centerList: viewModel.centerDataList)));
                    }),
                    child: Icon(Icons.list_outlined)),
              ),
            ),
            Visibility(
              visible: viewModel.loadingStatus == LoadingStatus.loading,
              child: Center (
                child: CircularProgressIndicator(),
              )
            )
          ],
        ),
      ),
    );
  }

  void currentLocation() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    print(permissionGranted);
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final GoogleMapController controller = await this.controller.future;
    await location.getLocation().then((res) {
      if (res.latitude != null && res.longitude != null) {
        controller.animateCamera(
            CameraUpdate.newLatLng(LatLng(res.latitude!, res.longitude!)));
      }
    });
  }

  Widget getGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
          target: LatLng(37.5666805, 126.9784147),
          zoom: 12
      ),
      onMapCreated: (GoogleMapController controller) {
        if (!this.controller.isCompleted) {
          //first calling is false
          // call "completer()"
          this.controller.complete(controller);
        }else{
          //other calling, later is true,
          // don't call again completer()
        }
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      onTap: (LatLng location) {
        setState(() {
          hideBottomView();
        });
      },
      markers: Set<Marker>.of(markers.values),
    );
  }

  void setMapMarker(List<CenterData>? centerDataList) {
    if (centerDataList != null) {
      Map<MarkerId, Marker> markers = new Map();
      for (var item in centerDataList) {
        MarkerId markerId = MarkerId(item.id);
        markers[markerId] = Marker(
            position: LatLng(double.parse(item.lat), double.parse(item.lng)),
            markerId: markerId,
            flat: true,
            onTap: () {
              print('markers onTap address : ' + item.address);
              showBottomView(item);
            }
        );

        this.markers = markers;
      }
    }
  }

  Widget getBottomInfoView() {
    return AnimatedPositioned(
        bottom: pinPillPosition, right: 0, left: 0,
        duration: Duration(milliseconds: 200),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(20),
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        blurRadius: 20,
                        offset: Offset.zero,
                        color: Colors.grey.withOpacity(0.5)
                    )]
              ),
              child: GestureDetector(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('${centerData?.centerName}'),
                            Text('${centerData?.phoneNumber}')
                          ],)
                      ]),
                  onTap: () {
                    Navigator.of(context).pushNamed('/detail', arguments: centerData);
                  }),
            )
        )  // end of Align
    );
  }

  void showBottomView(CenterData? centerData) {
    setState(() {
      pinPillPosition = 0;
      this.centerData = centerData;
    });
  }

  void hideBottomView() {
    setState(() {
      pinPillPosition = -100;
    });
  }

  // setMapViewFlag(bool value) async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   preferences.setBool('MapViewFlag', value);
  // }
  //
  // Future<bool> getMapViewFlag() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   var value = preferences.getBool('MapViewFlag');
  //   return value ?? false;
  // }

  /*Future<String> getJsonData() async {
    var url = 'https://api.odcloud.kr/api/15077586/v1/centers?page=1&perPage=300';
    var response = await http.get(Uri.parse(url),
        headers: {"Authorization": "Infuser 9fVBilb5dCRuro8bbduZX8+9m11eXNQ/6vRJu8aacsp9Cdyg2+nynid86DctiMQME7JOTWs1evJRFEKywsNqpA=="});
    setState(() {
      print('########################${response.body}');
      var dataConvertedToJSON = json.decode(response.body);
      List result = dataConvertedToJSON['data'];
      print('########################${result.length}');

      data.clear();
      Map<MarkerId, Marker> markers = new Map();
      for (var item in result) {
        print('########################${item['address'].toString()}');
        MarkerId markerId = MarkerId(item['id'].toString());
        String address = item['address'].toString();
        String centerName = item['centerName'].toString();
        String lat = item['lat'].toString();
        String lng = item['lng'].toString();
        String phoneNumber = item['phoneNumber'].toString();
        CenterData centerData = CenterData(item['id'].toString(), address, centerName, lat, lng, phoneNumber);
        markers[markerId] = Marker(
            position: LatLng(double.parse(item['lat'].toString()), double.parse(item['lng'].toString())),
            markerId: markerId,
            flat: true,
            onTap: () {
              print('markers onTap1 address : ' + address);
              showBottomView(centerData);
            }
        );

        this.markers = markers;

        data.add(centerData);
      }
    });
    return response.body;
  }*/
}