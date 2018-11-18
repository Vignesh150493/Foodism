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
  final int index;

  ProductCard(this.product, this.index);

  Widget _buildTitlePriceRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TitleDefault(product.title),
        SizedBox(
          width: 8.0,
        ),
        PriceTag(product.price.toString()),
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
                onPressed: () => Navigator.pushNamed<bool>(
                    context, '/product/' + model.allProducts[index].id)),
            IconButton(
                icon: Icon(model.allProducts[index].isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Colors.red,
                onPressed: () {
                  model.selectProduct(model.allProducts[index].id);
                  model.toggleProductFavouriteStatus();
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
          FadeInImage.memoryNetwork(
            image: product.image,
            height: 300.0,
            fit: BoxFit.cover,
            fadeInCurve: Curves.easeIn,
            placeholder: kTransparentImage,
          ),
          SizedBox(
            height: 10.0,
          ),
          _buildTitlePriceRow(),
          AddressTag(product.location.address),
          Text(product.userEmail),
          _buildActionButtons(context),
        ],
      ),
    );
  }
}
