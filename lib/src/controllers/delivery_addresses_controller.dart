import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/cart.dart';
import '../repository/cart_repository.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;

class DeliveryAddressesController extends ControllerMVC with ChangeNotifier {
  List<model.Address> addresses = <model.Address>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  Cart cart;
  List<dynamic> use = [];
  model.Address myAddress;
  DeliveryAddressesController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForAddresses();
    listenForCart();
  }

  void listenForAddresses({String message}) async {
    final Stream<model.Address> stream = await userRepo.getAddresses();
    stream.listen((model.Address _address) {
      setState(() {
        addresses.add(_address);
      });
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      cart = _cart;
    });
  }

  Future<void> refreshAddresses() async {
    addresses.clear();
    listenForAddresses(message: S.of(context).addresses_refreshed_successfuly);
  }

  Future<void> changeDeliveryAddress(model.Address address) async {
    await settingRepo.changeCurrentLocation(address);
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  Future<void> changeDeliveryAddressToCurrentLocation() async {
    model.Address _address = await settingRepo.setCurrentLocation();
    setState(() {
      settingRepo.deliveryAddress.value = _address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  static bool canDelivery(
      user_lat, user_long, market_latitude, market_longitude, market_range) {
    bool _can = true;
    String _unit = 'km';
    print(market_latitude);
    print(market_longitude);

    // double _deliveryRange = market_range;
    double _distance = 0.0;
    if (_unit == 'km') {
      market_range /= 1.60934;
    }

    _distance = sqrt(pow(69.1 * (double.parse(market_latitude) - user_lat), 2) +
        pow(
            69.1 *
                (user_long - double.parse(market_longitude)) *
                cos(double.parse(market_latitude) / 57.3),
            2));

    _can &= (_distance < market_range);
    print('if test ${_can}');
    return _can;
  }

  Future<dynamic> checkMarket(model.Address address) async {
    var result;
    final String url =
        '${GlobalConfiguration().getString('api_base_url')}markets';
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    await for (var contents in response.transform(Utf8Decoder())) {
      Map<String, dynamic> map = jsonDecode(contents);
      if (map['data'].toString() == '[]') {
        print('empty');
      } else {
        List<dynamic> Mapss = map['data'];
        use = map['data'];
        Mapss.forEach((Maped) {
          if (canDelivery(
                  address.latitude,
                  address.longitude,
                  Maped['latitude'],
                  Maped['longitude'],
                  Maped['delivery_range']) ==
              true) {
            print('returned');
            print(Maped['id']);
            result = Maped['id'];
          } else {
            return null;
          }
        });
      }
    }
    return result;
  }

  Future<bool> addAddress(model.Address address) async {
    dynamic result = await checkMarket(address);
    print('return result=$result');
    if (result != null) {
      address.market_id = result.toString();
      userRepo.addAddress(address).then((value) {
        setState(() {
          this.addresses.insert(0, value);
        });
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).new_address_added_successfully),
        ));
      });
      return true;
    } else {
      print('some issue');
      return false;
    }
  }

  Future<model.Address> newAddAddress(model.Address address) async {
    dynamic result = await checkMarket(address);
    if (result != null) {
      address.market_id = result.toString();
      model.Address addaddress = await userRepo.addAddress(address);
      setState(() {
        this.addresses.insert(0, addaddress);
      });
        return this.addresses.elementAt(0);

    }
    //addresses.forEach((_address) {

    //});
    //print("this.addresses.first");
    //print(this.addresses.single);

    else {
      return null;
    }
  }

  void chooseDeliveryAddress(model.Address address) {
    setState(() {
      settingRepo.deliveryAddress.value = address;
    });
    settingRepo.deliveryAddress.notifyListeners();
  }

  void updateAddress(model.Address address) async{
    dynamic result = await checkMarket(address);
     address.market_id = result.toString();
    userRepo.updateAddress(address).then((value) {
      setState(() {});
      addresses.clear();
      listenForAddresses(
          message: S.of(context).the_address_updated_successfully);
    });
  }

  void removeDeliveryAddress(model.Address address) async {
    userRepo.removeDeliveryAddress(address).then((value) {
      setState(() {
        this.addresses.remove(address);
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).delivery_address_removed_successfully),
      ));
    });
  }
}
