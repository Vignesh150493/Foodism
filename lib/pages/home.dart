import 'package:flutter/material.dart';
import '../widgets/productwidgets/product_summary_list.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main_scoped_model.dart';

class HomePage extends StatefulWidget {
  final MainScopedModel model;

  HomePage(this.model);

  @override
  HomePageState createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text("Choose"),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Manage Products"),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/admin');
            },
          )
        ],
      ),
    );
  }

  Widget _buildProductSummaryList() {
    return ScopedModelDescendant(
        builder: (context, widget, MainScopedModel model) {
      //Pull to refresh requires a scrollable view dude!
      //Refer [https://stackoverflow.com/questions/50195259/refresh-indicator-without-scrollview]
      Widget content = SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Center(
            child: Text("No Products found"),
          ),
          height: MediaQuery.of(context).size.height,
        ),
      );

      if (model.displayedProducts.length > 0 && !model.isLoading) {
        content = ProductList();
      } else if (model.isLoading) {
        content = Center(child: CircularProgressIndicator());
      }
      return RefreshIndicator(
        child: content,
        onRefresh: model.fetchProducts,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _buildDrawer(context),
        appBar: AppBar(
          title: Text('EasyList'),
          actions: <Widget>[
            ScopedModelDescendant<MainScopedModel>(
              builder: (context, widget, MainScopedModel model) {
                return IconButton(
                    icon: Icon(model.displayFavouritesOnly()
                        ? Icons.favorite
                        : Icons.favorite_border),
                    onPressed: () {
                      model.toggleDisplayMode();
                    });
              },
            ),
          ],
        ),
        body: _buildProductSummaryList());
  }

  @override
  void initState() {
    super.initState();
    widget.model.fetchProducts();
  }
}
