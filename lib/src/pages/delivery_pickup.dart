import 'package:flutter/material.dart';
import 'package:markets/src/elements/CardBottomDetails2.dart';
import 'package:markets/src/elements/CartBottomDetailsWidget.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../controllers/delivery_pickup_controller.dart';
import '../elements/CardBottomDetails2.dart';
import '../elements/DeliveryAddressDialog.dart';
import '../elements/DeliveryAddressesItemWidget.dart';
import '../elements/NotDeliverableAddressesItemWidget.dart';
import '../elements/PickUpMethodItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../models/payment_method.dart';
import '../models/route_argument.dart';
import '../pages/delievery_selection.dart';

class DeliveryPickupWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  DeliveryPickupWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _DeliveryPickupWidgetState createState() => _DeliveryPickupWidgetState();
}

class _DeliveryPickupWidgetState extends StateMVC<DeliveryPickupWidget> {
  DeliveryPickupController _con;
  bool pop = false;
  _DeliveryPickupWidgetState() : super(DeliveryPickupController()) {
    _con = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    _con.load2();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<HomeProvider>(context);
    if (_con.list == null) {
      _con.list = new PaymentMethodList(context);
      //  widget.pickup = widget.list.pickupList.elementAt(0);
      //  widget.delivery = widget.list.pickupList.elementAt(1);
    }
    return Scaffold(
      key: _con.scaffoldKey,
      bottomNavigationBar: _con.description != null
          ? CartBottomDetailsWidget2(
        con: _con,
      )
          : SizedBox(
        width: 0,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).delivery_or_pickup,
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Theme.of(context).hintColor,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[




            Column(
              children: <Widget>[

                _con.carts.isNotEmpty &&
                    Helper.canDelivery(_con.carts[0].product.market,
                        carts: _con.carts)
                    ? Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 38,
                    ),
                    title: _con.description != null
                        ? Text(_con.description)
                        : Text(S.of(context).address_not_selected),
                    subtitle: _con.description != null
                        ? Text(_con.address)
                        : Text(''),
                  ),
                )
                    : NotDeliverableAddressesItemWidget()
              ],
            ),
            _con.carts.isNotEmpty &&
                Helper.canDelivery(_con.carts[0].product.market,
                    carts: _con.carts)
                ?
            SingleChildScrollView(
                child: Container(
                    height: 400,
                    child: DeleiverySelection())):SizedBox(height: 0,)
          ],
        ),
      ),
    );
  }
}
