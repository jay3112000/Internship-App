import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:markets/src/elements/BlockButtonWidget.dart';
import 'package:markets/src/pages/home.dart';
import 'package:markets/src/pages/mobile_verification_2.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  TextEditingController _verify = TextEditingController();

  void startAddNewTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return GestureDetector(
            onTap: () {},
            child: Container(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Verify Your Account',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We are sending OTP to validate your mobile number. Hang on!',
                        style: Theme.of(context).textTheme.bodyText2,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      TextField(
                        controller: _verify,
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context)
                                    .focusColor
                                    .withOpacity(0.2)),
                          ),
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color:
                                  Theme.of(context).focusColor.withOpacity(0.5),
                            ),
                          ),
                          hintText: '0000',
                            hintStyle: TextStyle(color: Colors.grey)
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'SMS has been sent ',
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 50),
                      new BlockButtonWidget(
                        onPressed: () {
                          verify(_verify.text);
                        },
                        color: Theme.of(context).accentColor,
                        text: Text(S.of(context).verify.toUpperCase(),
                            style: Theme.of(context).textTheme.headline6.merge(
                                TextStyle(
                                    color: Theme.of(context).primaryColor))),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext)
              .pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      //Overlay.of(context).insert(loader);

      repository.registerwithphone(user.mobile, user.country).then((value) {
        if (value == true) {
          startAddNewTransaction(context);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text('This Number already exists!'),
          ));
        }
      });
    }
  }

  void verify(String code) async {
    print(code);
    FocusScope.of(context).unfocus();

    repository.verifyphone(code).then((value) {
      if (value == true) {
        register2();
      }
    });
  }

  void register2() async {
    FocusScope.of(context).unfocus();
    print('hg');
    print(user.name);
    Overlay.of(context).insert(loader);
    repository.register(user).then((value) {
      if (value != null && value.apiToken != null) {
        Navigator.of(scaffoldKey.currentContext)
            .pushReplacementNamed('/Pages', arguments: 2);
      } else {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).wrong_email_or_password),
        ));
      }
    }).catchError((e) {
      loader.remove();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).this_email_account_exists),
      ));
    }).whenComplete(() {
      Helper.hideLoader(loader);
    });
  }

  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content:
                Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext)
                    .pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
