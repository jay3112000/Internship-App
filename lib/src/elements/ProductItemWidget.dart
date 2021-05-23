import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:markets/src/controllers/home_controller.dart';
import 'package:markets/src/providers/home_provider.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../helpers/helper.dart';
import '../models/product.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ProductItemWidget extends StatefulWidget {
  final String heroTag;
  final Product product;

  const ProductItemWidget({Key key, this.product, this.heroTag})
      : super(key: key);

  @override
  _ProductItemWidgetState createState() => _ProductItemWidgetState();
}

class _ProductItemWidgetState extends StateMVC<ProductItemWidget> {
  HomeController _con;
  String productQuantity;
  _ProductItemWidgetState() : super(HomeController()) {
    _con = controller;
  }
  @override
  void initState() {
    // TODO: implement initState
    _con.listenForCart();

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final s = Provider.of<HomeProvider>(context);
    if (currentUser.value.apiToken == null) {
      productQuantity = _con.quantity.toString();
    } else {
      if (_con.cartLoadDone) {
        productQuantity = _con.findQuantity(widget.product.id).toString();
      } else {
        productQuantity = null;
      }
    }
    return InkWell(
      splashColor: Theme.of(context).accentColor,
      focusColor: Theme.of(context).accentColor,
      highlightColor: Theme.of(context).primaryColor,
      onTap: () {
        Navigator.of(context).pushNamed('/Product',
            arguments: RouteArgument(
                id: widget.product.id, heroTag: this.widget.heroTag));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.9),
          borderRadius: BorderRadius.all(Radius.circular(15)),
          boxShadow: [
            BoxShadow(
                color: Theme.of(context).focusColor.withOpacity(0.1),
                blurRadius: 5,
                offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: widget.heroTag + widget.product.id,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: CachedNetworkImage(
                  height: 140,
                  width: 170,
                  fit: BoxFit.cover,
                  imageUrl: widget.product.image.thumb,
                  placeholder: (context, url) => Image.asset(
                    'assets/img/loading.gif',
                    fit: BoxFit.cover,
                    height: 60,
                    width: 60,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(width: 5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          _con.language=="English"?
                          widget.product.name:widget.product.name_ar,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 2, right: 2,bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                Helper.getStarsList(widget.product.getRate()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0, left: 2, right: 2,bottom: 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                onPressed: () {
                                  if (productQuantity != null) {
                                    _con.decrementQuantity(widget.product);
                                    s.decrementQuantity(widget.product);
                                  }
                                },
                                iconSize: 25,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                icon: Icon(Icons.remove_circle_outline),
                                color: Theme.of(context).hintColor,
                              ),
                              productQuantity == null ? Shimmer.fromColors(child: Container(
                                width: 30,
                                height: 16.0,
                                color: Colors.white,
                              ), baseColor: Colors.grey[300],
                                  highlightColor: Colors.grey[100],) : Text(productQuantity,
                                  style: Theme.of(context).textTheme.subtitle2),
                              IconButton(
                                onPressed: () {
                                  if (currentUser.value.apiToken == null) {
                                    Navigator.of(context).pushNamed("/Login");
                                  } else {
                                    if (productQuantity != null) {
                                      s.ShowLoader().whenComplete(() => {
                                        _con.addToCart(widget.product)
                                            .then((value) {
                                          _con.incrementQuantity(widget.product);
                                          s.incrementQuantity(widget.product);
                                          s.stoploader();
                                        }),
                                      });
                                    }
                                  }
                                },
                                iconSize: 25,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                icon: Icon(Icons.add_circle_outline),
                                color: Theme.of(context).hintColor,
                              )
                            ],
                          ),
                        ),
                        /* SizedBox(
                          width: MediaQuery.of(context).size.width - 270,
                          child: FlatButton(
                            onPressed: () {
                              if (currentUser.value.apiToken == null) {
                                Navigator.of(context).pushNamed("/Login");
                              } else {
                                if (_con.isSameMarkets(_con.product)) {
                                  print(widget.product.id);
                                  _con.addToCart(widget.product);
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      // return object of type Dialog
                                      return AddToCartAlertDialogWidget(
                                          oldProduct:
                                              _con.carts.elementAt(0)?.product,
                                          newProduct: widget.product,
                                          onPressed: (product, {reset: true}) {
                                            return _con.addToCart(
                                                widget.product,
                                                reset: true);
                                          });
                                    },
                                  );
                                }
                              }
                            },
                            padding: EdgeInsets.symmetric(vertical: 14),
                            color: Theme.of(context).accentColor,
                            shape: StadiumBorder(),
                            child: Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                'Add to Cart',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),

                  Padding(
                      padding: const EdgeInsets.only(top: 0, left: 2, right: 2,bottom: 0),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Helper.getPrice(
                              widget.product.price,
                              context,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            widget.product.discountPrice > 0
                                ? Helper.getPrice(
                                    widget.product.discountPrice, context,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .merge(TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough)))
                                : SizedBox(height: 0),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            /* SizedBox(
              width: 170,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  SizedBox(height: 10),
                  /* Row(
                    children: <Widget>[
                      SizedBox(width: 10),
                      Stack(
                        fit: StackFit.loose,
                        alignment: AlignmentDirectional.centerEnd,
                        children: <Widget>[
                          SizedBox(
                            width: 160,
                            child: FlatButton(
                              onPressed: () {
                                if (currentUser.value.apiToken == null) {
                                  Navigator.of(context).pushNamed("/Login");
                                } else {
                                  if (_con.isSameMarkets(_con.product)) {
                                    print(widget.product.name);
                                    _con.addToCart(_con.product);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        // return object of type Dialog
                                        return AddToCartAlertDialogWidget(
                                            oldProduct: _con.carts
                                                .elementAt(0)
                                                ?.product,
                                            newProduct: _con.product,
                                            onPressed: (product,
                                                {reset: true}) {
                                              return _con.addToCart(
                                                  _con.product,
                                                  reset: true);
                                            });
                                      },
                                    );
                                  }
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 14),
                              color: Theme.of(context).accentColor,
                              shape: StadiumBorder(),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'add to cart',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),*/
                  SizedBox(height: 10),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
