import 'package:flutter/material.dart';
import 'location_model.dart';

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String imagePath;
  final bool isFavourite;
  final String userEmail;
  final String userId;
  final LocationModel location;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.image,
      @required this.imagePath,
      @required this.userEmail,
      @required this.userId,
      this.location,
      this.isFavourite = false});
}
