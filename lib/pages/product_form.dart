import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/product_scoped_model.dart';

class ProductForm extends StatefulWidget {
  @override
  _ProductFormState createState() {
    return new _ProductFormState();
  }
}

class _ProductFormState extends State<ProductForm> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'image': 'assets/food.jpg',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<ProductsScopedModel>(
      builder: (context, widget, ProductsScopedModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == null
            ? pageContent
            : Scaffold(
                appBar: AppBar(
                  title: Text('Edit Product'),
                ),
                body: pageContent,
              );
      },
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              SizedBox(
                height: 10.0,
              ),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<ProductsScopedModel>(
      builder: (context, widget, ProductsScopedModel model) {
        print("BuildSubmit Button " + model.products.length.toString());
        return RaisedButton(
          child: Text(
            'CREATE',
          ),
          textColor: Colors.white,
          onPressed: () => _submitForm(model.addProduct, model.updateProduct,
              model.selectedProductIndex),
        );
      },
    );
  }

  Widget _buildTitleTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.title,
      decoration: InputDecoration(labelText: 'Product Title'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Title is required';
        }
      },
      onSaved: (value) {
        _formData['title'] = value;
      },
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.description,
      decoration: InputDecoration(labelText: 'Product Description'),
      validator: (value) {
        if (value.isEmpty) {
          return 'Description is required';
        }
      },
      maxLines: 4,
      onSaved: (value) {
        _formData['description'] = value;
      },
    );
  }

  Widget _buildPriceTextField(Product product) {
    return TextFormField(
      initialValue: product == null ? '' : product.price.toString(),
      decoration: InputDecoration(labelText: 'Product Price'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.isEmpty ||
            !RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price is required and should be a number';
        }
      },
      onSaved: (value) {
        _formData['price'] = double.parse(value);
      },
    );
  }

  void _submitForm(Function addProduct, Function updateProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == null) {
      addProduct(Product(
          title: _formData['title'],
          description: _formData['description'],
          price: _formData['price'],
          image: _formData['image']));
    } else {
      updateProduct(
          Product(
              title: _formData['title'],
              description: _formData['description'],
              price: _formData['price'],
              image: _formData['image']));
    }
    Navigator.pushReplacementNamed(context, '/products');
  }
}
