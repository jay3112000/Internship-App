import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/checkout_controller.dart';
import '../../generated/l10n.dart';
import '../models/payment_method.dart';

// ignore: must_be_immutable
class PaymentMethodCashtemWidget extends StatefulWidget {
  PaymentMethod paymentMethod;

  PaymentMethodCashtemWidget({Key key, this.paymentMethod}) : super(key: key);

  @override
  _PaymentMethodCashtemWidgetState createState() => _PaymentMethodCashtemWidgetState();
}

class _PaymentMethodCashtemWidgetState extends StateMVC<PaymentMethodCashtemWidget> {
  CheckoutController _con;
  String heroTag;
  TextEditingController controller2 = TextEditingController();
  bool change=false;

  _PaymentMethodCashtemWidgetState() : super(CheckoutController()) {
    _con = controller;

  }
  void setchange(){
    setState(() {
      change=!change;
      print(change);
    });

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashColor: Theme.of(context).accentColor,
          focusColor: Theme.of(context).accentColor,
          highlightColor: Theme.of(context).primaryColor,
          onTap: () {
            Navigator.of(context).pushNamed(this.widget.paymentMethod.route);
            print(this.widget.paymentMethod.name);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.9),
              boxShadow: [
                BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.1), blurRadius: 5, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    image: DecorationImage(image: AssetImage('assets/img/cash.png'), fit: BoxFit.fill),
                  ),
                ),
                SizedBox(width: 15),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              S.of(context).cash_on_delivery,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical:8.0),
                                  child: Text(
                                    S.of(context).click_to_get_change,
                                    overflow: TextOverflow.fade,
                                    softWrap: false,
                                    style: Theme.of(context).textTheme.caption,
                                  ),
                                ),
                                change==false?
                                GestureDetector(
                                  onTap: setchange,
                                    child: Icon(Icons.check_box_outline_blank)):  GestureDetector(
                                    onTap: setchange,
                                    child: Icon(Icons.check_box))
                              ],
                            ),

                          ],
                        ),


                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_right,
                        color: Theme.of(context).focusColor,
                      ),
                    ],
                  ),
                )

              ],
            ),

          ),

        ),
        change==true?
            ListTile(
              leading: SizedBox(
                width: 20,
              ),
              tileColor: Colors.white,
              title: TextField(
                controller: controller2,
                keyboardType: TextInputType.number,
                onSubmitted: (value){
                          _con.getchange(controller2.text);

                },

                decoration: InputDecoration(

                  labelText: 'Enter amount of change',
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w100
                  )
                ),
              ),
              trailing: FlatButton(
                onPressed: (){

                  Navigator.of(context).pushNamed(this.widget.paymentMethod.route);
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                   color: Colors.green
                  ),
                ),

              ),
            ):SizedBox(
          height: 0,
        )
      ],
    );

  }
}
