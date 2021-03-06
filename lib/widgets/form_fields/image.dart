import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/product.dart';

class ImageInput extends StatefulWidget {

  final Function setImage;
  final Product product;


  ImageInput(this.setImage, this.product);

  @override
  _ImageInputState createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File _imageFile;

  void _getImage(BuildContext context, ImageSource source) {
    ImagePicker.pickImage(source: source, maxWidth: 400.0).then((File image) {
      setState(() {
        _imageFile = image;
      });
      widget.setImage(image);
      Navigator.pop(context);
    });
  }

  void openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Pick an image',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10.0,
                ),
                FlatButton(
                    textColor: Theme
                        .of(context)
                        .primaryColor,
                    onPressed: () {
                      _getImage(context, ImageSource.camera);
                    },
                    child: Text('Camera')),
                FlatButton(
                    textColor: Theme
                        .of(context)
                        .primaryColor,
                    onPressed: () {
                      _getImage(context, ImageSource.gallery);
                    },
                    child: Text('Gallery')),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme
        .of(context)
        .primaryColor;
    Widget previewImage = Text("Please select an image");

    if (_imageFile != null) {
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery
            .of(context)
            .size
            .width,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      previewImage = Image.network(widget.product.image, fit: BoxFit.cover,
        height: 300.0,
        width: MediaQuery
            .of(context)
            .size
            .width,
        alignment: Alignment.topCenter,);
    }
    return Column(
      children: <Widget>[
        OutlineButton(
          borderSide: BorderSide(color: color, width: 2.0),
          onPressed: () {
            openImagePicker(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt, color: color),
              SizedBox(
                width: 5.0,
              ),
              Text("Add Image",
                  style: TextStyle(
                    color: color,
                  ))
            ],
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        previewImage
      ],
    );
  }
}
