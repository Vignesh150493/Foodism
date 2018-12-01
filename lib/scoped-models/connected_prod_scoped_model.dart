import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import '../models/location_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';

//Note we can seperate the models by making them a lib
//https://stackoverflow.com/questions/13876879/how-do-you-namespace-a-dart-class
mixin ConnectedProdScopedModel on Model {
  List<Product> _products = [];
  String _selProdId;
  User _authenticatedUser;
  bool _isLoading = false;
}

mixin ProductsScopedModel on ConnectedProdScopedModel {
  bool _showFavourites = false;

  List<Product> get allProducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return _products.where((Product product) => product.isFavourite).toList();
    }
    return List.from(_products);
  }

  String get selectedProductId {
    return _selProdId;
  }

  Product get selectedProduct {
    if (_selProdId == null) {
      return null;
    }
    return _products.firstWhere((Product product) {
      return product.id == _selProdId;
    });
  }

  int get selectedProductIndex {
    return _products.indexWhere((Product product) {
      return product.id == _selProdId;
    });
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-foodie-products.cloudfunctions.net/storeImage'));
    final file = await http.MultipartFile.fromPath('image', image.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
    imageUploadRequest.files.add(file);

    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['Authorization'] = 'Bearer ${_authenticatedUser.token}';

    try {
      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print("Something went wrong");
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<bool> addProduct(String title, String description, File image,
      double price, LocationModel locationModel) async {
    _isLoading = true;
    notifyListeners();
    final uploadData = await uploadImage(image);

    if(uploadData == null) {
      print('Upload failed');
      return false;
    }

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'imagePath': uploadData['imagePath'],
      'imageUrl': uploadData['imageUrl'],
      'loc_lat': locationModel.latitude,
      'loc_lng': locationModel.longtitude,
      'loc_address': locationModel.address,
    };

    try {
      final http.Response response = await http.post(
          'https://foodie-products.firebaseio.com/products.json?auth=${_authenticatedUser.token}',
          body: json.encode(productData));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);
      final Product newProduct = Product(
          id: responseData['name'],
          title: title,
          description: description,
          price: price,
          location: locationModel,
          image: uploadData['imageUrl'],
          userEmail: _authenticatedUser.email,
          userId: _authenticatedUser.id);
      _products.add(newProduct);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct(String title, String description, String image,
      double price, LocationModel locModel) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> dataToUpdate = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
      'loc_lat': locModel.latitude,
      'loc_lng': locModel.longtitude,
      'loc_address': locModel.address,
    };
    return http
        .put(
            'https://foodie-products.firebaseio.com/products/${selectedProduct.id}.json?auth=${_authenticatedUser.token}',
            body: json.encode(dataToUpdate))
        .then((http.Response response) {
      _isLoading = false;
      _products[selectedProductIndex] = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          location: locModel,
          image: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<bool> deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProdId = null;
    notifyListeners();
    return http
        .delete(
            'https://foodie-products.firebaseio.com/products/$deletedProductId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return false;
    });
  }

  Future<Null> fetchProducts({onlyForUser = false}) {
    _isLoading = true;
    notifyListeners();
    return http
        .get(
            'https://foodie-products.firebaseio.com/products.json?auth=${_authenticatedUser.token}')
        .then<Null>((http.Response response) {
      final List<Product> fetchedProdList = [];
      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }
      productListData.forEach((String productId, dynamic productMap) {
        final Product product = Product(
            id: productId,
            title: productMap['title'],
            description: productMap['description'],
            price: productMap['price'],
            location: LocationModel(
              address: productMap['loc_address'],
              latitude: productMap['loc_lat'],
              longtitude: productMap['loc_lng'],
            ),
            image: productMap['image'],
            userEmail: productMap['userEmail'],
            userId: productMap['userId'],
            isFavourite: productMap['wishListUsers'] == null
                ? false
                : (productMap['wishListUsers'] as Map<String, dynamic>)
                    .containsKey(_authenticatedUser.id));
        fetchedProdList.add(product);
      });
      _products = onlyForUser
          ? fetchedProdList.where((Product product) {
              return product.userId == _authenticatedUser.id;
            }).toList()
          : fetchedProdList;
      _isLoading = false;
      notifyListeners();
      _selProdId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavouriteStatus() async {
    final bool isFavourite = selectedProduct.isFavourite;
    final bool newFavouriteStatus = !isFavourite;

    _products[selectedProductIndex] = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        location: selectedProduct.location,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: !isFavourite);
    notifyListeners();
    http.Response response;
    if (newFavouriteStatus) {
      response = await http.put(
          'https://foodie-products.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(true));
    } else {
      response = await http.delete(
          'https://foodie-products.firebaseio.com/products/${selectedProduct.id}/wishListUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      _products[selectedProductIndex] = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          location: selectedProduct.location,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId,
          isFavourite: !newFavouriteStatus);
      notifyListeners();
    }
  }

  void selectProduct(String productId) {
    _selProdId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }

  bool displayFavouritesOnly() {
    return _showFavourites;
  }
}

mixin UserScopedModel on ConnectedProdScopedModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user {
    return _authenticatedUser;
  }

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.LOGIN]) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };
    http.Response response;
    if (mode == AuthMode.LOGIN) {
      response = await http.post(
          'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDiVlj1fMw7dYgZPuZpgP4DVl3xOFWnl1w',
          body: json.encode(authData),
          headers: {
            'Content-Type': "application/json",
          });
    } else {
      response = await http.post(
        "https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDiVlj1fMw7dYgZPuZpgP4DVl3xOFWnl1w",
        body: json.encode(authData),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final Map<String, dynamic> responsedata = json.decode(response.body);
    bool hasError = true;
    String message = 'Something went wrong';
    if (responsedata.containsKey('idToken')) {
      hasError = false;
      message = 'Authentication Succeeded';
      _authenticatedUser = User(
          id: responsedata['localId'],
          email: email,
          token: responsedata['idToken']);
      setAuthTimeout(int.parse(responsedata['expiresIn']));
      _userSubject.add(true);
      final DateTime now = DateTime.now();
      final DateTime expiryTime =
          now.add(Duration(seconds: int.parse(responsedata['expiresIn'])));
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', responsedata['idToken']);
      prefs.setString('userEmail', email);
      prefs.setString('userId', responsedata['localId']);
      prefs.setString('expiryTime', expiryTime.toIso8601String());
    } else if (responsedata['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found';
    } else if (responsedata['error']['message'] == 'INVALID_PASSWORD') {
      message = 'This password in incorrect';
    } else if (responsedata['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists';
    }
    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  void autoAuthenticate() async {
    final prefs = await SharedPreferences.getInstance();
    final String token = prefs.get('token');
    final String expiryTimeString = prefs.getString('expiryTime');
    if (token != null) {
      final DateTime now = DateTime.now();
      final parsedExpiryTime = DateTime.parse(expiryTimeString);

      if (parsedExpiryTime.isBefore(now)) {
        _authenticatedUser = null;
        notifyListeners();
        return;
      }

      final String userEmail = prefs.get('userEmail');
      final String userId = prefs.get('userId');
      final int tokenLifeSpan = parsedExpiryTime.difference(now).inSeconds;
      _authenticatedUser = User(id: userId, email: userEmail, token: token);
      _userSubject.add(true);
      setAuthTimeout(tokenLifeSpan);
      notifyListeners();
    }
  }

  void logout() async {
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}

mixin UtilityScopedModel on ConnectedProdScopedModel {
  bool get isLoading {
    return _isLoading;
  }
}
