import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_project/util/sqlFavoriteUtil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sqflite/sqflite.dart';

import '../model/centerDataRes.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DetailPageState();
  }
}

class _DetailPageState extends State<DetailPage> {
  Completer<GoogleMapController> controller = Completer();
  late Future<Database> database;

  @override
  void initState() {
    super.initState();
    database = SqlFavoriteUtil.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    CenterData centerData = ModalRoute.of(context)!.settings.arguments as CenterData;

    return Scaffold(
      appBar: AppBar(title: Text(centerData.centerName),),
      body: Container(
        child: Column(
          children: [
            getGoogleMap(centerData),
            Expanded(
                child: ListView(
                  padding: EdgeInsets.all(20),
                  scrollDirection: Axis.vertical,
                  children: [
                    Text('명칭 : ${centerData.centerName}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text('주소 : ${centerData.address}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text('전화 : ${centerData.phoneNumber}',
                      style: TextStyle(fontSize: 18),
                    )
                  ],
                )
            ),
            ElevatedButton(
              child: Text('즐겨찾기 추가'),
              onPressed: () {
                SqlFavoriteUtil.insertFavorite(database, centerData);
                Fluttertoast.showToast(
                    msg: "즐겨찾기 추가되었습니다.",
                    gravity: ToastGravity.BOTTOM
                );
              },
            ),
          ],
        ),
      )
    );
  }

  Widget getGoogleMap(CenterData centerData) {
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(double.parse(centerData.lat), double.parse(centerData.lng)),
        zoom: 15
    );

    Map<MarkerId, Marker> markers = new Map();
    MarkerId markerId = MarkerId(centerData.id);
    markers[markerId] = Marker(
        position: LatLng(double.parse(centerData.lat), double.parse(centerData.lng)),
        markerId: markerId,
        flat: true,
    );

    return SizedBox(
      height: 300,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: cameraPosition,
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
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }
}