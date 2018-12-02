import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ProductFab extends StatefulWidget {
  final Product product;

  ProductFab(this.product);

  @override
  _ProductFabState createState() => _ProductFabState();
}

class _ProductFabState extends State<ProductFab> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant(
        builder: (context, widget, MainScopedModel model) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'contact',
                mini: true,
                onPressed: () async {
                  final url = 'mailto:${this.widget.product.userEmail}';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch';
                  }
                },
                child: Icon(
                  Icons.mail,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.0, 0.5, curve: Curves.easeOut)),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'favourite',
                mini: true,
                onPressed: () {
                  model.toggleProductFavouriteStatus();
                },
                child: Icon(
                  model.selectedProduct.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          FloatingActionButton(
            heroTag: 'options',
            onPressed: () {
              //Will be true if we never played the animation
              if (_controller.isDismissed) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: AnimatedBuilder(
                animation: _controller,
                builder: (context, widget) {
                  return Transform(
                      alignment: FractionalOffset.center,
                      transform: Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                      child: Icon(_controller.isDismissed ? Icons.more_vert : Icons.close));
                }),
          ),
        ],
      );
    });
  }
}
