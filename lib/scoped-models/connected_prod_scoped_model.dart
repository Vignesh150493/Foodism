import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../models/auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  Future<bool> addProduct(
      String title, String description, String image, double price) async {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
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
          image: image,
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

  Future<bool> updateProduct(
      String title, String description, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> dataToUpdate = {
      'title': title,
      'description': description,
      'image': 'https://moneyinc.com/wp-content/uploads/2017/07/Chocolate.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
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

  Future<Null> fetchProducts() {
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
            image: productMap['image'],
            userEmail: productMap['userEmail'],
            userId: productMap['userId']);
        fetchedProdList.add(product);
      });
      _products = fetchedProdList;
      _isLoading = false;
      notifyListeners();
      _selProdId = null;
    }).catchError((error) {
      _isLoading = false;
      notifyListeners();
      return;
    });
  }

  void toggleProductFavouriteStatus() {
    final bool isFavourite = selectedProduct.isFavourite;
    _products[selectedProductIndex] = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: !isFavourite);
    notifyListeners();
  }

  void selectProduct(String productId) {
    _selProdId = productId;
//    if (index != null) {
    notifyListeners();
//    }
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
}

mixin UtilityScopedModel on ConnectedProdScopedModel {
  bool get isLoading {
    return _isLoading;
  }
}
