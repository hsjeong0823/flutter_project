import 'package:flutter/material.dart';
import 'package:flutter_project/util/sqlFavoriteUtil.dart';
import 'package:sqflite/sqflite.dart';

import '../model/centerDataRes.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FavoritePageState();
  }
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<Database> database;
  late Future<List<CenterData>> centerList;

  @override
  void initState() {
    super.initState();
    database = SqlFavoriteUtil.initDatabase();
    centerList = SqlFavoriteUtil.getFavorite(database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorite Page'),),
      body: Container(
        child: Center(
            child: FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done){
                  if (snapshot.hasData) {
                    int length = (snapshot.data as List<CenterData>).length;
                    if (length == 0) {
                      return Text('No data');
                    }

                    return ListView.builder(itemBuilder: (context, index) {
                      CenterData data = (snapshot.data as List<CenterData>)[index];
                      // Card 위젯과 다르게 ListTile은 title, subtitle, leading, trailing옵션으로 위치를 지정
                      return ListTile(
                        title: Text(data.centerName, style: TextStyle(fontSize: 20),),
                        subtitle: Container(
                          child: Column(
                            children: [
                              Text(data.address),
                              Text(data.phoneNumber),
                              Container(height: 1, color: Colors.blue,)
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('/detail', arguments: data);
                        },

                        onLongPress: () async {
                          CenterData result = await showDialog(context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('${data.id} : ${data.centerName}'),
                              content: Text('${data.centerName}를 삭제하시겠습니까?'),
                              actions: [
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop(data);
                                }, child: Text('예')),
                                TextButton(onPressed: (){
                                  Navigator.of(context).pop();
                                }, child: Text('아니요')),
                              ],
                            );
                          });
                          if (result != null) {
                            SqlFavoriteUtil.deleteFavorite(database, result);
                            setState(() {
                              centerList = SqlFavoriteUtil.getFavorite(database);
                            });
                          }
                        },
                      );
                    }, itemCount: length);
                  } else {
                    return Text('No data');
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
              future: centerList,
            )
          )
      ),
    );
  }
}

