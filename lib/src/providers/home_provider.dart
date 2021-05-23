import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/market_repository.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';

import '../models/cart.dart';

class HomeProvider with ChangeNotifier {
  Market market;
  List<Category> categories = <Category>[];
  List<Market> topMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];
  List<Product> products = <Product>[];
  double myvalue = 0.0;
  bool loadCart = false;
  double quantity = 0;
  double total = 0;
  Product product;
  int cartCount = 0;
  List<Cart> carts = [];
  double taxAmount = 0.0;
  double deliveryFee = 0.0;

  double subTotal = 0.0;
  double total2;
  int myquantity = 0;
  bool check = false;
  bool pop=false;
  bool loader=false;
  bool todayselected=false;
  bool laterselected=false;
  void changepop() {
    pop =!pop;
    print('pop$pop');
    notifyListeners();
  }
  void changetodayselected() {
    todayselected =!todayselected;
    laterselected=false;

    notifyListeners();
  }
  void changelatersselected() {
    laterselected =!laterselected;
    todayselected=false;
    notifyListeners();
  }

  void addquantity(Product product ) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();


    product.productquantity++;
    prefs.setDouble('amountval', product.productquantity);
    notifyListeners();

  }

  void loadproductquantity() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getDouble('amountval')!=0)
      product.productquantity=prefs.getDouble('amountval');
    else{
      product.productquantity=0;
    }
    notifyListeners();

  }
  Future<void> ShowLoader() async{
    loader=true;
    print('loader$loader');
    notifyListeners();
  }

  void stoploader(){
    loader=false;
    print('loader$loader');
    notifyListeners();
  }
  SaveAmount(double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setDouble('amount', value);

  }
  LoadAmount() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(myvalue!=null){
      myvalue=prefs.getDouble('amount');
    }
    if(myvalue==null){
      myvalue=0;
    }
    notifyListeners();
  }

  SaveQuantity(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('quantity', value);

  }
  LoadQuantity() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(myquantity!=null){
      myquantity=prefs.getInt('quantity');
    }
    if(myquantity==null){
      myquantity=0;
    }
    notifyListeners();
  }


  void calculateSubtotal() async {
    subTotal = 0;
    if (carts.isNotEmpty)
      carts.forEach((cart) {
        subTotal += cart.product.price;
        cart.options.forEach((element) {
          subTotal += element.price;
        });
        subTotal *= cart.quantity;
      });
    if (Helper.canDelivery(carts[0].product.market, carts: carts)) {
      deliveryFee = carts[0].product.market.deliveryFee;
    }
    taxAmount =
        (subTotal + deliveryFee) * carts[0].product.market.defaultTax / 100;
    total2 = subTotal + taxAmount + deliveryFee;
    notifyListeners();
  }
  void updatepriceandquanity(carts)  {
    myvalue =  calculateSubtotalNew(carts);
    myquantity =  cartquantity(carts);
    notifyListeners();
  }

  static double checkDouble(dynamic value) {
    if (value is String) {
      return double.parse(value);
    } else {
      return value;
    }
  }


  double calculateSubtotalNew(carts)  {
    double cartPrice = 0;
    double subTotal = 0.0;
    carts.forEach((cart) {
      cartPrice = cart.product.price;
      cart.options.forEach((element) {
        cartPrice += element.price;
      });
      cartPrice *= cart.quantity;
      subTotal += cartPrice;
    });
    return subTotal;
  }

  int cartquantity(carts)  {
    double myquantity = 0.0;
    carts.forEach((cart) {
      myquantity += cart.quantity;
    });
    return myquantity.round();
  }

  incrementQuantity(Product product) {
    /*  var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options =
        product.options.where((element) => element.checked).toList();
        _newCart.quantity = this.quantity;*/

    if (this.quantity <= 99) {
      ++this.quantity;
      ++this.myquantity;
      myvalue = myvalue + product.price;
      SaveAmount(myvalue);
      SaveQuantity(myquantity);
      notifyListeners();
    }
  }

  decrementQuantity(Product product) {
    if (this.quantity > 1 && this.myquantity>1) {
      --this.quantity;
      --this.myquantity;
      myvalue = myvalue - product.price;
      SaveAmount(myvalue);
      SaveQuantity(myquantity);
      notifyListeners();
    }
  }
  ondismiss(Cart cart){
    myquantity=myquantity-cart.quantity.round();
    myvalue=myvalue-cart.product.price*cart.quantity;
    SaveAmount(myvalue);
    SaveQuantity(myquantity);
    notifyListeners();
  }

  void emptycart() async {
    myquantity = 0;
    myvalue = 0.0;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt('quantity', 0);
    prefs.setDouble('amount', 0);
    notifyListeners();
  }

  /*void listenForMyMarket() async {
    SharedPreferences prefs5 = await SharedPreferences.getInstance();
    final market_id = prefs5.getString('id');
    Uri uri = Helper.getUri('api/markets/$market_id');
    Map<String, dynamic> _queryParams = {};

    uri = uri.replace(queryParameters: _queryParams);
    try {
      final client = new http.Client();
      final streamedRest = await client.send(http.Request('get', uri));

      return streamedRest.stream
          .transform(utf8.decoder)
          .transform(json.decoder)
          .map((data) => Helper.getData(data))
          .map((data) {
        print('mymarket:$data');

        return Market.fromJSON(data);
      }
      );
    }catch (e) {
      print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
      return new Stream.value(new Market.fromJSON({}));
    }
*/


}
