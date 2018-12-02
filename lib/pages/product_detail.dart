import 'package:flutter/material.dart';
import '../widgets/common/title_default.dart';
import '../models/product.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:map_view/map_view.dart';

class ProductDetail extends StatelessWidget {
  final Product product;

  ProductDetail(this.product);

  void _showMap() {
    final List<Marker> markers = <Marker>[
      Marker('position', 'Position', product.location.latitude,
          product.location.longtitude)
    ];
    final mapView = MapView();
    final cameraPosition = CameraPosition(
        Location(product.location.latitude, product.location.longtitude), 14.0);
    mapView.show(
        MapOptions(
            mapViewType: MapViewType.normal,
            title: 'Product Location',
            initialCameraPosition: cameraPosition),
        toolbarActions: [ToolbarAction('Close', 1)]);
    mapView.onToolbarAction.listen((id) {
      if (id == 1) {
        mapView.dismiss();
      }
    });
    mapView.onMapReady.listen((_) {
      mapView.setMarkers(markers);
    });
  }

  Widget _buildAddressPriceRow(double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
//        GestureDetector(
//          onTap: _showMap,
//          child: Text(
//            product.location.address,
//            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
//          ),
//        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            child: Text(
              '|',
              style: TextStyle(color: Colors.grey),
            )),
        Text(
          '\$' + price.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //Onwillpop we are blocking the default back pressed behaviour here.
      onWillPop: () {
        Navigator.pop(context, false);
        return Future.value(false);
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(product.title),
          ),
          body: Column(
            //Cross axis is horizontal centering
            //Main axis is vertical
            children: <Widget>[
              FadeInImage.memoryNetwork(
                image: product.image,
                height: 300.0,
                fit: BoxFit.cover,
                fadeInCurve: Curves.easeIn,
                placeholder: kTransparentImage,
              ),
              Container(
                  padding: EdgeInsets.all(10.0),
                  child: TitleDefault(product.title)),
              _buildAddressPriceRow(product.price),
              Container(
                child: Text(
                  product.description,
                  textAlign: TextAlign.center,
                ),
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(top: 10.0),
              ),
            ],
          )),
    );
  }
}
