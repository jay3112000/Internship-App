import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;

class RazorPayController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  WebViewController webView;
  String url = "";
  double progress = 0;
  Address deliveryAddress;
  String address;

  RazorPayController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }
  @override
  void initState() {
    final String _apiToken = 'api_token=${userRepo.currentUser.value.apiToken}';
    final String _deliveryAddress = 'delivery_address_id=${settingRepo.deliveryAddress.value?.address_id}';
    final String _couponCode = 'coupon_code=${settingRepo.coupon?.code}';
    url =
    '${GlobalConfiguration().getString('base_url')}payments/paytap/checkout?$_apiToken&$_deliveryAddress&$_couponCode';
    print(url);
    setState(() {});
    super.initState();
  }
}
