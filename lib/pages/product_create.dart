import 'package:flutter/material.dart';

class ProductCreate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () {
          showModalBottomSheet(context: context, builder: (context) {
            return Center(
              child: Text('Modal'),
            );
          });
        },
        child: Text('Save'),
      ),
    );
  }
}
