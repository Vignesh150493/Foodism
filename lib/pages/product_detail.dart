import 'package:flutter/material.dart';

class ProductDetail extends StatelessWidget {
  final String title;
  final String imageUrl;

  ProductDetail(this.title, this.imageUrl);

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
            title: Text(title),
          ),
          body: Column(
            //Cross axis is horizontal centering
            //Main axis is vertical
            children: <Widget>[
              Image.asset(imageUrl),
              Container(padding: EdgeInsets.all(10.0), child: Text(title)),
              Container(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: Theme.of(context).accentColor,
                  child: Text('Delete'),
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              )
            ],
          )),
    );
  }

  _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text('This action cannot be undone'),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('CONTINUE'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }
}
