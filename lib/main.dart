import 'package:flutter/material.dart';
import 'pages/auth.dart';
import 'pages/product_admin.dart';
import 'pages/home.dart';
import 'pages/product_detail.dart';
import 'models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import 'scoped-models/main_scoped_model.dart';
//import 'package:flutter/rendering.dart';

void main() {
//  debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  final MainScopedModel model = MainScopedModel();
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainScopedModel>(
      //Model would be passed to materialapp and all its children.
      model: model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple,
            fontFamily: 'Google'),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/products': (BuildContext context) => HomePage(model),
          '/admin': (BuildContext context) => ProductAdmin(model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final int index = int.parse(pathElements[2]);
            return MaterialPageRoute<bool>(
                builder: (context) => ProductDetail(index));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (context) => HomePage(model));
        },
      ),
    );
  }
}
