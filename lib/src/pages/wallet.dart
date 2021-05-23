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

class WalletScreen extends StatefulWidget {
  final RouteArgument routeArgument;

  WalletScreen({Key key, this.routeArgument}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends StateMVC<WalletScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Your Wallet',
          style: Theme.of(context)
              .textTheme
              .headline6
              .merge(TextStyle(letterSpacing: 1.3)),
        ),

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Center(
              child: Container(
              child:  Column(
                  children: [
                    Text("Wallet Balance",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'ProductSans',
                      ),

                    ),
                    Text('40',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 20,
                        fontFamily: 'ProductSans',
                      ),
                    )
                  ],
                )

              ),
            )


          ],
        ),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
          onPressed: () =>  Navigator.of(context).pushNamed('/AddMoney')),

    );
  }
}
