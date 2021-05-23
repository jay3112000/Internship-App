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

class AddMoney extends StatefulWidget {
  final RouteArgument routeArgument;

  AddMoney({Key key, this.routeArgument}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends StateMVC<AddMoney> {
  TextEditingController controller2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add Money',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: TextField(
                            controller: controller2,
                            keyboardType: TextInputType.number,
                            onSubmitted: (value){


                            },

                            decoration: InputDecoration(

                                labelText: 'Enter amount to Add',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w100
                                )
                            ),
                          ),

                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * .9,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: Colors.white,
                      ),
                      child: RaisedButton.icon(
                        color: Colors.green,
                          onPressed: () {
                            Navigator.of(context).pushNamed('/AddMoney');
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Submit',
                            style: TextStyle(
                              color: Colors.white,
                                fontFamily: "KumbhSans", fontSize: 16),
                          )),
                    ),
                  ),
                    ],
                  )

              ),
            )


          ],
        ),
      ),
    );
  }
}
