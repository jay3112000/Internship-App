import 'package:flutter/material.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../helpers/helper.dart';
import '../models/address.dart' as model;

class CartBottomDetailsWidget2 extends StatelessWidget {
  const CartBottomDetailsWidget2({

    Key key,
    @required CartController con,
  })  : _con = con,
        super(key: key);

  final CartController _con;

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<HomeProvider>(context);
    return _con.carts.isEmpty
        ? SizedBox(height: 0)
        : Container(
      height: 200,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.15),
                offset: Offset(0, -2),
                blurRadius: 5.0)
          ]),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    S.of(context).subtotal,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Helper.getPrice(_con.subTotal, context,
                    style: Theme.of(context).textTheme.subtitle1,
                    zeroPlaceholder: '0')
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    S.of(context).delivery_fee,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                if (Helper.canDelivery(_con.carts[0].product.market,
                    carts: _con.carts))
                  Helper.getPrice(
                      _con.carts[0].product.market.deliveryFee, context,
                      style: Theme.of(context).textTheme.subtitle1,
                      zeroPlaceholder: 'Free')
                else
                  Helper.getPrice(0, context,
                      style: Theme.of(context).textTheme.subtitle1,
                      zeroPlaceholder: 'Free')
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${S.of(context).tax} (${_con.carts[0].product.market.defaultTax}%)',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Helper.getPrice(_con.taxAmount, context,
                    style: Theme.of(context).textTheme.subtitle1)
              ],
            ),
            SizedBox(height: 10),
            Stack(
              fit: StackFit.loose,
              alignment: AlignmentDirectional.centerEnd,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: FlatButton(
                    onPressed: () {

                      s.todayselected==true||s.laterselected==true?

                        Navigator.of(context).pushNamed('/PaymentMethod'):null;


                    },
                    disabledColor:
                    Theme.of(context).focusColor.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    color: !_con.carts[0].product.market.closed
                        ? Theme.of(context).accentColor
                        : Theme.of(context).focusColor.withOpacity(0.5),
                    shape: StadiumBorder(),
                    child: Text(
                      S.of(context).checkout,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyText1.merge(
                          TextStyle(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Helper.getPrice(_con.total, context,
                      style: Theme.of(context).textTheme.headline4.merge(
                          TextStyle(
                              color: Theme.of(context).primaryColor)),
                      zeroPlaceholder: 'Free'),
                )
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
