import 'package:flutter/material.dart';
import 'price_tag.dart';
import '../common/title_default.dart';
import 'address_tag.dart';
import '../../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../scoped-models/main_scoped_model.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  ProductCard(this.product);

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: TitleDefault(product.title)),
        Flexible(
          child: SizedBox(
            width: 8.0,
          ),
        ),
        Flexible(child: PriceTag(product.price.toString())),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(
      builder: (context, widget, MainScopedModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.info),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  model.selectProduct(product.id);
                  Navigator.pushNamed<bool>(
                          context, '/product/' + product.id)
                      .then((_) => model.selectProduct(null));
                }),
            IconButton(
                icon: Icon(product.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
//                  model.selectProduct(product.id);
                  model.toggleProductFavouriteStatus(product);
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Hero(
            tag: product.id,
            child: FadeInImage.memoryNetwork(
              image: product.image,
              height: 300.0,
              fit: BoxFit.cover,
              fadeInCurve: Curves.easeIn,
              placeholder: kTransparentImage,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          _buildTitlePriceRow(),
          SizedBox(height: 10.0,),
//          AddressTag(product.location.address),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
