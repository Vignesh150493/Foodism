import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'models/product.dart';
import 'pages/auth.dart';
import 'pages/home.dart';
import 'pages/product_admin.dart';
import 'pages/product_detail.dart';
import 'scoped-models/main_scoped_model.dart';
import 'helpers/custom_route.dart';
import 'config_constants.dart';
import 'adaptive_theme.dart';
//import 'package:flutter/rendering.dart';

void main() {
//  debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  MapView.setApiKey(API_KEY);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final MainScopedModel _model = MainScopedModel();
  final _platformChannel = MethodChannel('platform-channel/battery');
  bool _isAuthenticated = false;

  Future<Null> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await _platformChannel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level is $result %';
    } catch(error) {
      batteryLevel = 'Failed to get battery level';
    }
    print(batteryLevel);
  }

  @override
  void initState() {
    super.initState();
    _model.userSubject.listen((bool isAuthenticated) {
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    _getBatteryLevel();
    _model.autoAuthenticate();
  }

  //Why is rxdart subject here, preferred over scoped model?
  //In scoped model, on notify listeners, the entire widget tree of descendants is built.
  //Flutter is smart enough to look for changes and paint only the widgets that are changed, but still.
  //In our case we just listen to main model. Maybe we can make it seperate scoped models.
  // But since, here we have products and users, which kind of interact, everything came into single scoped model.
  //U use subject, and we can decide what to target, more specifically.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainScopedModel>(
      //Model would be passed to materialapp and all its children.
      model: _model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: getAdaptiveThemeData(context),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : HomePage(_model),
          '/admin': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : ProductAdmin(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          if (!_isAuthenticated) {
            return MaterialPageRoute<bool>(builder: (context) => AuthPage());
          }
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product =
                _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return CustomRoute<bool>(
                builder: (context) =>
                    !_isAuthenticated ? AuthPage() : ProductDetail(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
              builder: (context) =>
                  !_isAuthenticated ? AuthPage() : HomePage(_model));
        },
      ),
    );
  }
}
