import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../models/product.dart';
import '../models/location_model.dart';
import '../scoped-models/main_scoped_model.dart';
import '../widgets/form_fields/location.dart';
import '../widgets/form_fields/image.dart';

import 'dart:io';

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
    'image': null,
    'location': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainScopedModel>(
      builder: (context, widget, MainScopedModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
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
//              LocationInput(_setLocation, product),
              SizedBox(
                height: 10.0,
              ),
              ImageInput(_setImage, product),
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
    return ScopedModelDescendant<MainScopedModel>(
      builder: (context, widget, MainScopedModel model) {
        print("BuildSubmit Button " + model.allProducts.length.toString());
        return model.isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : RaisedButton(
                child: Text(
                  'CREATE',
                ),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex),
              );
      },
    );
  }

  Widget _buildTitleTextField(Product product) {
    if (product == null && _titleTextController.text.trim() == '') {
      _titleTextController.text = '';
    } else if (product != null && _titleTextController.text.trim() == '') {
      _titleTextController.text = product.title;
    } else if (product != null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else if (product == null && _titleTextController.text.trim() != '') {
      _titleTextController.text = _titleTextController.text;
    } else {
      _titleTextController.text = '';
    }
    return TextFormField(
      controller: _titleTextController,
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
    if (product == null && _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = '';
    } else if (product != null &&
        _descriptionTextController.text.trim() == '') {
      _descriptionTextController.text = product.description;
    }
    return TextFormField(
      controller: _descriptionTextController,
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
    if (product == null && _priceTextController.text.trim() == '') {
      _priceTextController.text = '';
    } else if (product != null && _priceTextController.text.trim() == '') {
      _priceTextController.text = product.description;
    }
    return TextFormField(
      controller: _priceTextController,
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

  void _setLocation(LocationModel model) {
    _formData['location'] = model;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedProductIndex]) {
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedProductIndex == -1)) {
      return;
    }
    _formKey.currentState.save();
    if (selectedProductIndex == -1) {
      addProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text),
//        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/products').then((_) {
            setSelectedProduct(null);
          });
        } else {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Something went wrong"),
                  content: Text('Please try again'),
                  actions: <Widget>[
                    FlatButton(
                        onPressed: Navigator.of(context).pop,
                        child: Text('OKAY'))
                  ],
                );
              });
        }
      });
    } else {
      updateProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text),
//        _formData['location'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/products').then((_) {
          setSelectedProduct(null);
        });
      });
    }
  }
}
