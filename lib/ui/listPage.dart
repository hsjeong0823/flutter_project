import 'package:flutter/material.dart';

import '../model/centerDataRes.dart';

class ListPage extends StatefulWidget {
  final List<CenterData>? centerList;
  const ListPage({Key? key, this.centerList}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ListPageState();
  }
}

class _ListPageState extends State<ListPage> {
  static const String ALL_SELECTED = '전체';
  Set<String> cityList = {ALL_SELECTED};
  String selectedCity = ALL_SELECTED;
  List<CenterData>? filterList;

  @override
  void initState() {
    super.initState();
    for (var data in widget.centerList!) {
      cityList.add(data.sido);
    }
    filterList = getCenterList(selectedCity);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: DropdownButton(
            isExpanded: true,
            value: selectedCity,
            items: cityList.map((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),);
              }).toList(),
            onChanged: (value) {
              setState(() {
                selectedCity = value as String;
                filterList = getCenterList(selectedCity);
              });
            },
          ),
        ),
        body: filterList != null && filterList!.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  return Container(
                      height: 70,
                      child: Card(
                        child: InkWell(
                          child: Center(
                              child: Text(
                                filterList![index].centerName,
                            style: TextStyle(fontSize: 18),
                          )),
                          onTap: () {
                            Navigator.of(context).pushNamed('/detail',
                                arguments: filterList![index]);
                          },
                        ),
                      ));
                },
                itemCount: filterList!.length,
              )
            : Center(
                child: Text('No Data'),
              ));
  }

  List<CenterData>? getCenterList(String selectedCity) {
    if (selectedCity == ALL_SELECTED) {
      return widget.centerList;
    }

    List<CenterData>? list = widget.centerList?.where((element) => (element.sido).contains(selectedCity)).toList();
    return list;
  }
}
