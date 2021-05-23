
import 'package:flutter/material.dart';
import 'dart:core';
import '../../generated/l10n.dart';
import '../elements/PaymentMethodListItemWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/checkout_controller.dart';
import 'package:smart_select/smart_select.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:provider/provider.dart';

class DeleiverySelection extends StatefulWidget {
  final RouteArgument routeArgument;

  DeleiverySelection({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeleiverySelectionState createState() => _DeleiverySelectionState();
}

class _DeleiverySelectionState extends StateMVC<DeleiverySelection> {
  CheckoutController _con;
  bool arrowicon = false;
  bool dayarrrow = false;
  bool showlist = false;
  bool dayarrrow2 = false;
  bool nowseleceted=false;
  bool laterselected=false;
  bool todayarrow = false;

  String opentime = '';
  String closetime = '';
  String intervaltime = '';
  String breaktime = '';
  bool checkbox = false;
  String finalDate = '';
  List<String> weekdays = [];
  List<int> time = [];
  DateTime open_time;
  DateTime close_time;
  DateTime your_time;
  int interval_time;
  int break_time;
  List<String> mytimes = [];
  String orderday;
  String oredertime;
  var i = 0;
  int starttime;
  int endtime;
  List<TimeOfDay> now = [];
  List<String> times = [];
 int selected=0;
 int selected2=0;
 String timetosend='';
 String valuechoose='Tomorrow';
 List<String>myoptions=['Tomorrow','Day After Tomorrow'];
  _DeleiverySelectionState() : super(CheckoutController()) {
    _con = controller;
  }
  void loadtime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    opentime = prefs.getString('open_time');
    closetime = prefs.getString('close_time');
    intervaltime = prefs.getString('interval_time');
    breaktime = prefs.getString('break_time');
    print(opentime);
    print(breaktime);
    print(intervaltime);
    open_time = new DateFormat("hh:mm", 'en_US').parse(opentime);
    close_time = new DateFormat("hh:mm", 'en_US').parse(closetime);
    interval_time = int.parse(intervaltime);
    break_time = int.parse(breaktime);
    print(open_time);
    starttime = open_time.hour;
    endtime = close_time.hour;

    var mytime = '';
    if (break_time == 0) {
      for (i = starttime; i <= endtime; i = i + interval_time) {
        mytime = i.toString() +
            ':' +
            breaktime +
            '-' +
            (i + interval_time).toString() +
            ':' +
            breaktime;
        times.add(mytime);
      }
      times[0] =
          starttime.toString() +':'+breaktime+ '-' + (starttime + interval_time).toString()+':'+breaktime;
      times.removeAt(times.length - 2);
      times[times.length - 1] = (endtime - interval_time).toString() +
          ":" +
          breaktime +
          '-' +
          endtime.toString()+':'+breaktime;
    }
    if (break_time >= 60) {
      int j = (break_time ~/ 60).toInt();
      print("j$j");
      int a = (break_time % 60).toInt();

      for (i = starttime + j; i <= endtime; i = i + interval_time) {
        {
          mytime = i.toString() +
              ':' +
              a.toString() +
              '-' +
              (i + interval_time).toString() +
              ':' +
              a.toString();
          times.add(mytime);
        }
      }
    }
    if (0 < break_time && break_time < 60) {
      for (i = starttime; i <= endtime; i = i + interval_time) {
        mytime = i.toString() +
            ':' +
            breaktime +
            '-' +
            (i + interval_time).toString() +
            ':' +
            breaktime;
        times.add(mytime);
      }
      times[0] =
          starttime.toString() + '-' + (starttime + interval_time).toString();
      times.removeAt(times.length - 2);
      times[times.length - 1] = (endtime - interval_time).toString() +
          ":" +
          breaktime +
          '-' +
          endtime.toString();
    }

    mytimes = times.map((e) => e.toString()).toList();
    timetosend=mytimes[0];
    print(times);
    print('mytimes$mytimes');
  }

  void oderday(String day) {
    orderday = day;
    _con.getday(orderday);
    print(orderday);
  }

  void setcheckbox() {
    setState(() {
      checkbox = !checkbox;
      print(checkbox);
    });
  }
  void setcnowselected() {
    setState(() {
      nowseleceted = !nowseleceted;
      print(nowseleceted);
    });
  }
  void setlaterselected() {
    setState(() {
      laterselected = !laterselected;
      print('later$laterselected');
    });
  }

  void ordertime(String time) {
    oredertime = time;
    _con.gettime(oredertime);
    print(oredertime);
  }

  getCurrentDate() {
    DateTime date = DateTime.now();
    String dat = DateFormat('EEEE').format(date);
    String dat2 = DateFormat("HH:mm").format(date);
    your_time = new DateFormat("HH").parse(dat2);

    if (dat == 'Monday') {
      weekdays = [
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
        'Monday'
      ];
    }
    if (dat == 'Tuesday') {
      weekdays = [
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
        'Monday',
        'Tuesday'
      ];
    }
    if (dat == 'Wednesday') {
      weekdays = [
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday'
      ];
    }
    if (dat == 'Thursday') {
      weekdays = [
        'Friday',
        'Saturday',
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday'
      ];
    }
    if (dat == 'Friday') {
      weekdays = [
        'Saturday',
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ];
    }
    if (dat == 'Saturday') {
      weekdays = [
        'Sunday',
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday'
      ];
    }
    if (dat == 'Sunday') {
      weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
    }

    print(weekdays);
  }

  List<String> _checked = [];

  void change_arrow() {
    setState(() {
      arrowicon = !arrowicon;
    });
    print(arrowicon);
  }

  void change_dayarrow() {
    setState(() {
      dayarrrow = !dayarrrow;
    });
  }

  void change_todayarrow() {
    setState(() {
      todayarrow = !todayarrow;
    });
  }

  void change_dayarrow2() {
    setState(() {
      dayarrrow2 = !dayarrrow2;
    });
  }


  Future<bool> checktime() async {
    if (open_time.hour < your_time.hour && your_time.hour < close_time.hour) {
      print(open_time.hour);
      print(your_time);
      print(close_time.hour);
      return true;
    } else {
      print(open_time.hour);
      print(your_time.hour);
      print(close_time.hour);
      return false;
    }
  }

  void _showMyDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).delivery_not_available_at_this_moment),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).you_can_schedule_your_delivery,
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).schedule_delivery,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void clickdialogue()async{
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose Time'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Please select a checkbox',
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ok',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }



  @override
  void initState() {
    getCurrentDate();
    loadtime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<HomeProvider>(context);
    return
            SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    leading: Icon(
                      Icons.home,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).delivery_options,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle:
                        Text(S.of(context).select_your_preferred_delivery_method),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    checktime().then((value) => {
                          if (value == true)
                            {

                              oderday('today'),
                              /*dayarrrow == true ? change_dayarrow() : null,
                              dayarrrow2 == true ? change_dayarrow2() : null,*/
                              setcnowselected(),
                              laterselected==true?setlaterselected():null,
                              s.changetodayselected(),
                            }
                          else
                            {_showMyDialog()}
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: ListTile(
                      tileColor: nowseleceted==true?Colors.green:Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.confirmation_num,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      title: Text(
                        S.of(context).deliver_now,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),

                    ),
                  ),
                ),
               /* todayarrow == true
                    ? /*Container(
                        height: 300,
                        child: ListView.builder(
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 300,
                                    width: 200,
                                    child: ListView.builder(
                                        itemCount: mytimes.length,
                                        itemBuilder: (context, index) {
                                          return CheckboxGroup(
                                            labelStyle: TextStyle(fontSize: 16),
                                            labels: [mytimes[index]],
                                            checked: _checked,
                                            onChange: (bool isChecked, String label,
                                                int index) {
                                              ordertime(label);
                                              setcheckbox();
                                              print(
                                                  "isChecked: $isChecked   label: $label  index: $index");
                                            },
                                            onSelected: (List selected) =>
                                                setState(() {
                                              if (selected.length > 1) {
                                                selected.removeAt(0);
                                                print(
                                                    'selected length  ${selected.length}');
                                              } else {
                                                print("only one");
                                              }
                                              _checked = selected;
                                            }),
                                          );
                                        }),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        height: 300,
                                        width: 100,
                                        child: ListView.builder(
                                            itemCount: mytimes.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: SizedBox(
                                                  width: 55,
                                                  height: 30,
                                                  child: RaisedButton(
                                                    onPressed: () {
                                                      if (checkbox == true)
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                '/PaymentMethod');
                                                      else {
                                                        clickdialogue();
                                                      }
                                                    },
                                                    color: Colors.green,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30.0),
                                                    ),
                                                    child: Text(
                                                      'done',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )*/
               */
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
                  child: GestureDetector(
                    onTap: () {
                      change_arrow();
                      setlaterselected();
                      nowseleceted==true?setcnowselected():null;
                      oderday(myoptions[0]);
                      ordertime(mytimes[0]);
                      s.changelatersselected();

                    },
                    child: ListTile(
                      tileColor: laterselected==true?Colors.green:Colors.white,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.lock_clock,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      title: Text(
                        S.of(context).deliver_later,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: laterselected == false
                            ? Icon(Icons.arrow_right_sharp)
                            : Icon(Icons.arrow_downward_rounded),
                      ),
                    ),
                  ),
                ),
                laterselected == true
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Card(
                              elevation: 2,
                              child: DropdownButton(
                                value: valuechoose,
                                isExpanded: true,

                                icon: Icon(Icons.unfold_more),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontFamily: 'ProductSans',
                                ),
                                onChanged: (newvalue){

                                  setState(() {
                                    valuechoose=newvalue;
                                  });
                                  oderday(newvalue.toString());
                                },
                                items: myoptions.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(e),
                                    ),
                                  );
                                }).toList(),

                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: Card(
                              elevation: 2,
                              child: DropdownButton(
                                value: timetosend,
                                isExpanded: true,

                                icon: Icon(Icons.arrow_downward_sharp),
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 20,
                                  fontFamily: 'ProductSans',
                                ),
                                onChanged: (newvalue){
                                  setState(() {
                                    timetosend=newvalue;
                                  });
                                  ordertime(newvalue.toString());
                                },
                                items: mytimes.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),

                              ),
                            ),
                          ),



                         /* GestureDetector(
                            onTap: () {
                              change_dayarrow();
                              oderday(weekdays[0]);
                              todayarrow == true ? change_todayarrow() : null;
                              dayarrrow2 == true ? change_dayarrow2() : null;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: ListTile(
                                tileColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 60),
                                  child: Text(
                                    S.of(context).tomorrow,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: dayarrrow == false
                                      ? Icon(Icons.arrow_right_sharp)
                                      : Icon(Icons.arrow_downward_sharp),
                                ),
                              ),
                            ),
                          ),*/


                         /* GestureDetector(
                            onTap: () {
                              change_dayarrow2();
                              oderday(weekdays[1]);
                              todayarrow == true ? change_todayarrow() : null;
                              dayarrrow == true ? change_dayarrow() : null;
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0),
                              child: ListTile(
                                tileColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 60),
                                  child: Text(
                                    S.of(context).day_after_tomorrow,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: dayarrrow2 == false
                                      ? Icon(Icons.arrow_right_outlined)
                                      : Icon(Icons.arrow_downward),
                                ),
                              ),
                            ),
                          ),*/

                        ],
                      )
                    : SizedBox(
                        height: 0,
                      )
              ],
            ),



      );
  }
}


