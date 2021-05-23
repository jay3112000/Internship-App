import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:markets/src/controllers/home_controller.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/helper.dart' as helper;

class HomeDropDown extends StatefulWidget {
  final String adress;
  final String description;
  final String latitude;
  final String longitude;
  HomeDropDown(this.adress, this.description, this.latitude, this.longitude);

  @override
  _HomeDropDownState createState() => _HomeDropDownState();
}

class _HomeDropDownState extends StateMVC<HomeDropDown> {
  HomeController _con;
  List<String> checked = [];
  _HomeDropDownState() : super(HomeController()) {
    _con = controller;
  }
  save(String lat, String lon, String descr, String addre) async {
    SharedPreferences prefs1 = await SharedPreferences.getInstance();
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    SharedPreferences prefs3 = await SharedPreferences.getInstance();
    SharedPreferences prefs4 = await SharedPreferences.getInstance();

    prefs1.setString('lat', lat);
    prefs2.setString('lon', lon);
    prefs3.setString('desc', descr);
    prefs4.setString('address', addre);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: CheckboxGroup(labels: _con.lst 

          /*value: checked,
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(widget.description),
        subtitle: Text(widget.adress),
        onChanged: (bool value) {
          setState(() {
            checked = value;
          });
          
          save(widget.latitude, widget.longitude, widget.description,
              widget.adress);
          helper.Helper.load();
        },*/
          ),
    );
  }
}
