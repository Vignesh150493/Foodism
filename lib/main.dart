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
  final MainScopedModel _model = MainScopedModel();

  @override
  void initState() {
    super.initState();
    _model.autoAuthenticate();
  }
  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainScopedModel>(
      //Model would be passed to materialapp and all its children.
      model: _model,
      child: MaterialApp(
        // debugShowMaterialGrid: true,
        theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.deepOrange,
            accentColor: Colors.deepPurple,
            buttonColor: Colors.deepPurple,
            fontFamily: 'Google'),
        routes: {
          '/': (BuildContext context) => ScopedModelDescendant(
            builder: (context, widget, MainScopedModel model) {
              return model.user == null ? AuthPage() : HomePage(_model);
            },
          ),
          '/products': (BuildContext context) => HomePage(_model),
          '/admin': (BuildContext context) => ProductAdmin(_model),
        },
        onGenerateRoute: (RouteSettings settings) {
          final List<String> pathElements = settings.name.split('/');
          if (pathElements[0] != '') {
            return null;
          }
          if (pathElements[1] == 'product') {
            final String productId = pathElements[2];
            final Product product = _model.allProducts.firstWhere((Product product) {
              return product.id == productId;
            });
            return MaterialPageRoute<bool>(
                builder: (context) => ProductDetail(product));
          }
          return null;
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(builder: (context) => HomePage(_model));
        },
      ),
    );
  }
}
