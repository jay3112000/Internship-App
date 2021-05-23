import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../helpers/helper.dart' as helper;
import '../models/slide.dart';
import '../repository/slider_repository.dart';
import 'package:http/http.dart' as http;

class HomeController extends ControllerMVC {
  Market market;
  List<dynamic> mymarket = <Market>[];
  List<Category> categories = <Category>[];
  List<Market> topMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];
  List<Product> products = <Product>[];
  List<Slide> slides = <Slide>[];

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
  File jsonFile;
  Directory dir;
  String fileName = "myJSONFile.json";
  bool fileExists = false;
  Map<String, String> fileContent;
  List<dynamic> myadrees;
  GlobalKey<ScaffoldState> scaffoldKey;
  List<dynamic> lst = [];
  String market_id;
  bool loader=false;
  String language="Arabic";
  String opentime='';
  HomeController() {
    loadmarketid();
    listenForSlides();
    calculateTotal();
    listenForTopMarkets();
    getalladresses();
    loadlang();
    helper.Helper.load();

  }

  bool cartLoadDone = false;

  void getalladresses() async {
    myadrees = await getAddresses3();
    print('values');

    lst = myadrees;
  }
  void loadlang()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();

    language=prefs.getString('language')!=null?prefs.getString('language'):"Arabic";


  }
  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }
  void loadmarketid() async {
    SharedPreferences prefs5 = await SharedPreferences.getInstance();
    market_id = prefs5.getString('id');
    print('marketidsaved=$market_id');
    listenForProducts(market_id);
   listenForMyMarket(market_id);
  }

  findQuantity(product_id) {
    double quant = 0;
    carts.forEach((cart) {
      if (product_id.toString() == cart.product.id.toString()) {
        quant = cart.quantity;
      }
    });
    return quant;
  }

  void removeFromCart(Cart _cart) async {
    setState(() {
      this.carts.remove(_cart);
    });
    removeCart(_cart).then((value) {
      calculateSubtotal();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S
            .of(context)
            .the_product_was_removed_from_your_cart(_cart.product.name)),
      ));
    });
  }

  Future<void> removeFromCart2() async {
    emptyCart().then((value) {
      return value;
    });
  }

  savePreferences(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setDouble('quantity', product.productquantity);
    print(product.productquantity);
  }

  loadPreferences(Product product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    product.productquantity = prefs.getDouble('quantity');
  }



  void listenForCarts({String message}) async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cartLoadDone = false;
      if (!carts.contains(_cart)) {
        setState(() {
          carts.add(_cart);
        });
      }
    }, onDone: () {
      cartLoadDone = true;
      if (carts.isNotEmpty) {
        //calculateSubtotal();
      }

    });
  }

  void calculateSubtotal() async {
    subTotal = 0;
    carts.forEach((cart) {
      subTotal += cart.product.price;
      cart.options.forEach((element) {
        subTotal += element.price;
      });
      subTotal *= cart.quantity;
      print(subTotal);
    });
    if (Helper.canDelivery(carts[0].product.market, carts: carts)) {
      deliveryFee = carts[0].product.market.deliveryFee;
    }
    taxAmount =
        (subTotal + deliveryFee) * carts[0].product.market.defaultTax / 100;
    total2 = subTotal + taxAmount + deliveryFee;

    setState(() {});
  }

  void listenForCartsCount({String message}) async {
    final Stream<int> stream = await getCartCount();
    stream.listen((int _count) {
      setState(() {
        this.cartCount = _count;
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    });
  }

  Future<bool> addToCart(Product product, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
      this.cartLoadDone = false;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options =
        product.options.where((element) => element.checked).toList();
    _newCart.quantity = 1;
    // if product exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      _oldCart.quantity += 1;
      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
          this.cartLoadDone = true;
        });
      }).whenComplete(() {});
    } else {
      // the product doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        listenForCarts();
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {});
    }
    return true;
  }

  bool isSameMarkets(Product product) {
    print('issame');
    if (carts.isNotEmpty) {
      return carts[0].product?.market?.id == product.market?.id;
    }
    return true;
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart),
        orElse: () => null);
  }

  void calculateTotal() {
    total = product?.price ?? 0;
    product?.options?.forEach((option) {
      total += option.checked ? option.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity(Product product) {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity(Product product) {
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.product = product;
    _newCart.options =
        product.options.where((element) => element.checked).toList();
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      if (_oldCart.quantity > 1) {
        --_oldCart.quantity;
        updateCart(_oldCart).then((value) {
          setState(() {
            this.loadCart = false;
          });
        }).whenComplete(() {
          calculateTotal();
        });
      }
    }
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cartLoadDone = false;
      carts.add(_cart);
    }).onDone(() {
      cartLoadDone = true;
    });
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();

    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      categories.insert(0, new Category.fromJSON({'id': '1', 'name': 'all','name_ar':'الكل'}));
    });
  }

  void  listenForProducts(String idMarket, {List<String> categoriesId}) async {
    print('marketid=$idMarket');
    if (idMarket == null) {
      idMarket = '1';
    }
    final Stream<Product> stream =
        await getProductsOfMarket(idMarket, categories: categoriesId);
    stream.listen((Product _product) {
      setState(() => products.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {
      calculateTotal();
    });
  }

  Future<void> selectCategory(List<String> categoriesId) async {
    products.clear();
    listenForProducts(market_id, categoriesId: categoriesId);
  }

  Future<void> listenForTopMarkets() async {
    final Stream<Market> stream =
        await getNearMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularMarkets() async {
    final Stream<Market> stream =
        await getPopularMarkets(deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => popularMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForTrendingProducts(String idMarket) async {
    final Stream<Product> stream = await getTrendingProductsOfMarket(idMarket);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  void listenForMyMarket(String market_id) async {
    final mymarket = await getMarket2(market_id);
    print(mymarket);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('open_time', mymarket.first['open_time']);
    prefs.setString('close_time', mymarket[1]['close_time']);
    prefs.setString('interval_time', mymarket[2]['interval_time']);
    prefs.setString('break_time', mymarket[3]['brake_time']);


  }

  Future<void> refreshHome() async {
    setState(() {
      categories = <Category>[];
      slides = <Slide>[];
      listenForCartsCount();
    });
    await listenForCategories();
    await getalladresses();
    await calculateTotal();
    await listenForSlides();
  }
}
