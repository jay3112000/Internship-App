import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';
import '../elements/ProductItemWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../helpers/helper.dart' as helper;
import '../models/order.dart' as order;
import '../elements/HomeSliderWidget.dart';
class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  List<String> _checked = [];
  List<String> selectedCategories;
  String adress;
  String description;
  String latitude;
  String longitude;
  String delieverto;
  double totalamount;
  int toalquanitiy;
  bool approve;
  bool approvecart;
  _HomeWidgetState() : super(HomeController()) {
    _con = controller;

  }
  void showsheet(ctx) {
    showModalBottomSheet(
        context: ctx,
        builder: (_) {
          return Container(
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(S.of(context).deliver_to),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                      color: Colors.green,
                      child: Row(
                        children: [
                          Text(
                            S.of(context).new_location,
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                          )
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pushNamed('/DeliveryAddresses');
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    child: FutureBuilder(
                        future: getAddresses3(),
                        builder: (context, value) {
                          if (value.hasData) {
                            return ListView.builder(
                              itemCount: _con.lst.length,
                              itemBuilder: (context, index) {
                                return CheckboxGroup(
                                    labelStyle: TextStyle(fontSize: 16),
                                    labels: [
                                      _con.lst[index]['description'].toString()
                                    ],
                                    checked: _checked,
                                    onChange: (bool isChecked, String label,
                                        int index) =>
                                        print(
                                            "isChecked: $isChecked   label: $label  index: $index"),
                                    onSelected: (List selected) {
                                      _con.market_id.toString() !=
                                          _con.lst[index]['market_id']
                                              .toString()
                                          ? _showMyDialog().then((value) => {
                                        print(value),
                                        if (value == true)
                                          {
                                            setState(() {
                                              if (selected.length > 1) {
                                                selected.removeAt(0);
                                                print(
                                                    'selected length  ${selected.length}');
                                              } else {
                                                print("only one");
                                              }
                                              _checked = selected;

                                              save(
                                                  _con.lst[index]
                                                  ['address']
                                                      .toString(),
                                                  _con.lst[index][
                                                  'description']
                                                      .toString(),
                                                  _con.lst[index]
                                                  ['latitude']
                                                      .toString(),
                                                  _con.lst[index]
                                                  ['longitude']
                                                      .toString(),
                                                  _con.lst[index]
                                                  ['market_id']
                                                      .toString(),
                                                  _con.lst[index]['id']
                                                      .toString(),


                                              );

                                              helper.Helper.load();
                                              order.Order.loadaddress();
                                              delieverto = _con
                                                  .lst[index]
                                              ['description']
                                                  .toString();
                                              toalquanitiy = 0;
                                              totalamount = 0.0;

                                              _con.removeFromCart2().then((value) {
                                                Provider.of<HomeProvider>(
                                                    context,
                                                    listen: false).emptycart();
                                                Navigator.of(context)
                                                    .pushNamed('/Cart');
                                              });

                                            })
                                          }
                                        else
                                          {print('cancel')}
                                      })
                                          : setState(() {
                                        if (selected.length > 1) {
                                          selected.removeAt(0);
                                          print(
                                              'selected length  ${selected.length}');
                                        } else {
                                          print("only one");
                                        }
                                        _checked = selected;

                                        save(
                                            _con.lst[index]['address']
                                                .toString(),
                                            _con.lst[index]['description']
                                                .toString(),
                                            _con.lst[index]['latitude']
                                                .toString(),
                                            _con.lst[index]['longitude']
                                                .toString(),
                                            _con.lst[index]['market_id']
                                                .toString(),
                                            _con.lst[index]['id']
                                                .toString(),

                                        );


                                        helper.Helper.load();
                                        order.Order.loadaddress();
                                        delieverto = _con.lst[index]
                                        ['description']
                                            .toString();
                                        Navigator.of(context)
                                            .pushNamed('/Pages');

                                      });
                                    });
                              },
                            );
                          } else {
                            return CircularLoadingWidget(
                              height: 20,
                            );
                          }
                        }),
                  ),
                ),
              ],
            ),
          );
        });
  }

  save(String addre, String descr, String lat, String lon, String id,
      String deliever_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('lat', lat);
    prefs.setString('lon', lon);
    prefs.setString('desc', descr);
    prefs.setString('address', addre);
    prefs.setString('id', id);
    prefs.setString('del_id', deliever_id);

  }

  loadadress() async {
    SharedPreferences prefs3 = await SharedPreferences.getInstance();
    delieverto = prefs3.getString('desc');
    delieverto == null && currentUser.value.apiToken != null
        ? showsheet(context)
        : null;
    print('deliver$delieverto');
  }

  Future<bool> _showMyDialog() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).address_change_alert),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).if_you_change_the_address_your_cart_will_be_emptied,
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
                Text(
                  S.of(context).would_you_like_to_approve_of_this_message,
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                approve = false;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                S.of(context).approve,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                approve = true;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return approve;
  }
  Future<bool> _showCancelCart() async {
    await showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).cart_empty_alert),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  S.of(context).your_cart_will_be_emptied,
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
                Text(
                  S.of(context).would_you_like_to_approve_of_this_message,
                  style: TextStyle(fontFamily: 'ProductSans'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                approvecart = false;
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text(
                S.of(context).approve,
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                approvecart = true;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return approvecart;
  }

  @override
  void initState() {

    _con.listenForCategories();
    _con.listenForCartsCount();
    //_con.calculateSubtotal();
    selectedCategories = ['0'];
   // _con.calculateTotal();
    //_con.listenForCart();
   _con.listenForCarts();
    Provider.of<HomeProvider>(
        context,
        listen: false).LoadAmount();

    Provider.of<HomeProvider>(
        context,
        listen: false).LoadQuantity();
    loadadress();

    super.initState();
    order.Order.loadaddress();
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<HomeProvider>(context);
     double height = MediaQuery.of(context).size.width * .4;
        double width = MediaQuery.of(context).size.width * .58;
    /* if(s.myvalue == 0) {
      print("test true");
      if(currentUser.value.apiToken != null) {
        totalamount = s.calculateSubtotalNew(_con.carts);
        s.myvalue = totalamount;
      }
      else {
        print("test false");
        totalamount = s.myvalue;
      }
    }
    else {
      totalamount = s.myvalue;
    }
    if(s.myquantity == 0.0) {
      if(currentUser.value.apiToken != null) {
        toalquanitiy = s.cartquantity(_con.carts);
        s.myquantity = toalquanitiy;
      }
      else {
        toalquanitiy = s.myquantity;
      }
    }
    else {
      toalquanitiy = s.myquantity;
    }*/
    return Scaffold(

        appBar: AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
            onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: ValueListenableBuilder(
            valueListenable: settingsRepo.setting,
            builder: (context, value, child) {
              return Text(
                value.appName ?? S.of(context).home,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .merge(TextStyle(letterSpacing: 1.3)),
              );
            },
          ),
          actions: <Widget>[
            new ShoppingCartButtonWidget(
                iconColor: Theme.of(context).hintColor,
                labelColor: Theme.of(context).accentColor),
          ],
        ),
        body: currentUser.value.apiToken != null
            ? FutureBuilder<dynamic>(
            future: getAddresses2(),
            builder: (context, value) {
              if (value.toString().contains('true')) {
                return RefreshIndicator(
                  onRefresh: _con.refreshHome,
                  child: Stack(
                    children: <Widget>[
                      SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                            horizontal: 0, vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 2),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text( S.of(context).deliver_to),

                                    Icon(
                                      Icons.location_on,
                                      color: Colors.green,
                                    ),
                                    delieverto != null
                                        ? GestureDetector(
                                      onTap: () {
                                        showsheet(context);
                                      },
                                      child: Text(
                                        delieverto,
                                        style: TextStyle(
                                            color: Colors.green),
                                      ),
                                    )
                                        : SizedBox(
                                      width: 0,
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.arrow_drop_down),
                                      onPressed: () {
                                        showsheet(context);
                                      },
                                      color: Colors.green,
                                    ),
                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20),
                              child: SearchBarWidget(
                                onClickFilter: (event) {
                                  widget.parentScaffoldKey.currentState
                                      .openEndDrawer();
                                },
                              ),
                            ),
              Padding(
              padding: const EdgeInsets.symmetric(
              horizontal: 10),
              child: HomeSliderWidget(slides: _con.slides),
              ),


                           Container(
                              height: 70,
                              child: ListView(
                                primary: false,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                children: List.generate(
                                    _con.categories.length, (index) {
                                  var _category =
                                  _con.categories.elementAt(index);
                                  var _selected = this
                                      .selectedCategories
                                      .contains(_category.id);
                                  return Padding(
                                    padding:
                                    const EdgeInsetsDirectional.only(
                                        start: 20),
                                    child: RawChip(
                                      elevation: 0,
                                      label:_con.language=="English"?Text(_category.name)!=null?Text(_category.name):Text('all'):Text(_category.name_ar)!=null?Text(_category.name_ar):Text('all'),
                                      labelStyle: _selected
                                          ? Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          .merge(TextStyle(
                                          color: Theme.of(context)
                                              .primaryColor))
                                          : Theme.of(context)
                                          .textTheme
                                          .bodyText2,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 15),
                                      backgroundColor: Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.1),
                                      selectedColor:
                                      Theme.of(context).accentColor,
                                      selected: _selected,
                                      //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                                      showCheckmark: false,
                                      avatar: (_category.id == '0')
                                          ? null
                                          : (_category.image.url
                                          .toLowerCase()
                                          .endsWith('.svg')
                                          ? SvgPicture.network(
                                        _category.image.url,
                                        color: _selected
                                            ? Theme.of(context)
                                            .primaryColor
                                            : Theme.of(context)
                                            .accentColor,
                                      )
                                          : CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                        _category.image.icon,
                                        placeholder:
                                            (context, url) =>
                                            Image.asset(
                                              'assets/img/loading.gif',
                                              fit: BoxFit.cover,
                                            ),
                                        errorWidget: (context,
                                            url, error) =>
                                            Icon(Icons.error),
                                      )),
                                      onSelected: (bool value) {
                                        setState(() {
                                          if (_category.id == '0') {
                                            this.selectedCategories = ['0'];
                                          } else {
                                            this
                                                .selectedCategories
                                                .removeWhere((element) =>
                                            element == '0');
                                          }
                                          if (value) {
                                            this
                                                .selectedCategories
                                                .add(_category.id);
                                          } else {
                                            this
                                                .selectedCategories
                                                .removeWhere((element) =>
                                            element ==
                                                _category.id);
                                          }
                                          _con.selectCategory(
                                              this.selectedCategories);
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                            _con.products.isEmpty || s.loader==true
                                ? CircularLoadingWidget(height: 250)
                            /*: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _con.products.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return ProductItemWidget(
                      heroTag: 'menu_list',
                      product: _con.products.elementAt(index),
                    );
                  },
                ),*/

                                : GridView.builder(
                              gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: MediaQuery.of(context)
                                                                                              .size
                                                                                              .width *.5,
                                childAspectRatio: height / width,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: _con.products.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  elevation: 5,
                                  child: ProductItemWidget(
                                    heroTag: 'menu_list',
                                    product: _con.products
                                        .elementAt(index),
                                  ),
                                );
                              },
                              primary: false,
                              shrinkWrap: true,
                            ),
                            SizedBox(
                              height: 140,
                            )
                          ],
                        ),
                      ),
                      s.myquantity != 0
                          ? Positioned(
                        bottom: 0,
                        child:  Container(
                          height: 135,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              border: Border(
                                top: BorderSide(
                                    color: Colors.grey, width: 2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: Theme.of(context)
                                        .focusColor
                                        .withOpacity(0.15),
                                    offset: Offset(0, -2),
                                    blurRadius: 5.0)
                              ]),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width -
                                40,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        S.of(context).total_number_of_items,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                    Text(s.myquantity.toString()),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        S.of(context).total_amount,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ),
                                    /* s.total2 != null
                              ? Text(s.total2.toString())
                              : Text('ss'),*/

                                    Text(s.myvalue.toString()),
                                    /* Helper.getPrice(s.subTotal, context,
                                    style:
                                        Theme.of(context).textTheme.subtitle1)*/
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                      ),
                                      width: MediaQuery.of(context)
                                          .size
                                          .width -
                                          245,
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pushNamed('/Cart');
                                        },
                                        disabledColor:
                                        Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14),
                                        color: Theme.of(context)
                                            .accentColor,
                                        child: Text(
                                          S.of(context).cart,
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .merge(TextStyle(
                                              color: Theme.of(
                                                  context)
                                                  .primaryColor)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                      ),
                                      width: MediaQuery.of(context)
                                          .size
                                          .width -
                                          245,
                                      child: FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        onPressed: () {
                                          _showCancelCart().then((value) => {
                                            if(value==true){
                                              _con.removeFromCart2().then((value) {
                                            s.emptycart();
                                              Navigator.of(context)
                                                .pushNamed('/Pages');
                                              })
                                            }
                                            else {

                                            }


                                          });

                                        },
                                        disabledColor:
                                        Theme.of(context)
                                            .focusColor
                                            .withOpacity(0.5),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 14),
                                        color: Colors.red,
                                        child: Text(
                                          S.of(context).cancel,
                                          textAlign: TextAlign.start,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyText1
                                              .merge(TextStyle(
                                              color: Theme.of(
                                                  context)
                                                  .primaryColor)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: 0,
                      ),
                    ],
                  ),
                );
              } else if (value.toString().contains('false')) {
                return Center(
                  child: Container(
                    height: 250,
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 5,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.error,
                                color: Colors.green,
                                size: 77,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(S.of(context).we_need_a_delivery_address),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RaisedButton(
                                  color: Colors.green,
                                  child: Text(S.of(context).add_address,
                                      style: TextStyle(
                                        color: Colors.white,
                                      )),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushNamed('/DeliveryAddresses');
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                    child: CircularProgressIndicator(
                        backgroundColor: Colors.green));
              }
            })
            : RefreshIndicator(
          onRefresh: _con.refreshHome,
          child: Stack(
            children: <Widget>[
              SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SearchBarWidget(
                        onClickFilter: (event) {
                          widget.parentScaffoldKey.currentState
                              .openEndDrawer();
                        },
                      ),
                    ),
                    Container(
                      height: 90,
                      child: ListView(
                        primary: false,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(_con.categories.length,
                                (index) {
                              var _category =
                              _con.categories.elementAt(index);
                              var _selected = this
                                  .selectedCategories
                                  .contains(_category.id);
                              return Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 20),
                                child: RawChip(
                                  elevation: 0,
                                  label:_con.language=="English"?Text(_category.name)!=null?Text(_category.name):Text('all'):Text(_category.name_ar)!=null?Text(_category.name_ar):Text('all'),
                                  labelStyle: _selected
                                      ? Theme.of(context)
                                      .textTheme
                                      .bodyText2
                                      .merge(TextStyle(
                                      color: Theme.of(context)
                                          .primaryColor))
                                      : Theme.of(context).textTheme.bodyText2,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 15),
                                  backgroundColor: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.1),
                                  selectedColor:
                                  Theme.of(context).accentColor,
                                  selected: _selected,
                                  //shape: StadiumBorder(side: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.05))),
                                  showCheckmark: false,
                                  avatar: (_category.id == '0')
                                      ? null
                                      : (_category.image.url
                                      .toLowerCase()
                                      .endsWith('.svg')
                                      ? SvgPicture.network(
                                    _category.image.url,
                                    color: _selected
                                        ? Theme.of(context)
                                        .primaryColor
                                        : Theme.of(context)
                                        .accentColor,
                                  )
                                      : CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: _category.image.icon,
                                    placeholder: (context, url) =>
                                        Image.asset(
                                          'assets/img/loading.gif',
                                          fit: BoxFit.cover,
                                        ),
                                    errorWidget:
                                        (context, url, error) =>
                                        Icon(Icons.error),
                                  )),
                                  onSelected: (bool value) {
                                    setState(() {
                                      if (_category.id == '0') {
                                        this.selectedCategories = ['0'];
                                      } else {
                                        this.selectedCategories.removeWhere(
                                                (element) => element == '0');
                                      }
                                      if (value) {
                                        this
                                            .selectedCategories
                                            .add(_category.id);
                                      } else {
                                        this.selectedCategories.removeWhere(
                                                (element) =>
                                            element == _category.id);
                                      }
                                      _con.selectCategory(
                                          this.selectedCategories);
                                    });
                                  },
                                ),
                              );
                            }),
                      ),
                    ),
                    _con.products.isEmpty
                        ? CircularLoadingWidget(height: 250)
                    /*: ListView.separated(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  primary: false,
                  itemCount: _con.products.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 10);
                  },
                  itemBuilder: (context, index) {
                    return ProductItemWidget(
                      heroTag: 'menu_list',
                      product: _con.products.elementAt(index),
                    );
                  },
                ),*/

                        : GridView.builder(
                      gridDelegate:
                      SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: height / width,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _con.products.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: ProductItemWidget(
                            heroTag: 'menu_list',
                            product: _con.products.elementAt(index),
                          ),
                        );
                      },
                      primary: false,
                      shrinkWrap: true,
                    ),
                    SizedBox(
                      height: 140,
                    )
                  ],
                ),
              ),


              SizedBox(
                height: 0,
              ),
            ],
          ),
        ));
  }
}