import 'package:flutter/material.dart';
import 'package:flutter_project/ui/favoritePage.dart';
import 'package:flutter_project/viewmodel/mapPageViewModel.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'mapPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: controller,
        children: [
          ChangeNotifierProvider<MapPageViewModel>(
              create: (_) => MapPageViewModel(),
              child: MapPage()
          ),
          FavoritePage()
        ],
      ),
      bottomNavigationBar: TabBar(tabs: [
        Tab(icon: Icon(Icons.map_outlined, color: Colors.blue,),),
        Tab(icon: Icon(Icons.star_outline, color: Colors.blue,),)
      ], controller: controller,),
    );
  }
}