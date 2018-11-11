import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

//Note we can seperate the models by making them a lib
//https://stackoverflow.com/questions/13876879/how-do-you-namespace-a-dart-class
mixin ConnectedProdScopedModel on Model {
  List<Product> _products = [];
  int _selProdIndex;
  User _authenticatedUser;
  bool _isLoading = false;

  Future<Null> addProduct(
      String title, String description, String image, double price) {
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
    return http
        .post('https://foodie-products.firebaseio.com/products.json',
            body: json.encode(productData))
        .then((http.Response response) {
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
    });
  }
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

  int get selectedProductIndex {
    return _selProdIndex;
  }

  Product get selectedProduct {
    if (_selProdIndex == null) {
      return null;
    }
    return _products[_selProdIndex];
  }

  Future<Null> updateProduct(
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
            'https://foodie-products.firebaseio.com/products/${selectedProduct.id}.json',
            body: json.encode(dataToUpdate))
        .then((http.Response response) {
      _isLoading = false;
      _products[_selProdIndex] = Product(
          id: selectedProduct.id,
          title: title,
          description: description,
          price: price,
          image: image,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(_selProdIndex);
    _selProdIndex = null;
    notifyListeners();
    http
        .delete(
            'https://foodie-products.firebaseio.com/products/$deletedProductId.json')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get('https://foodie-products.firebaseio.com/products.json')
        .then((http.Response response) {
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
    });
  }

  void toggleProductFavouriteStatus() {
    final bool isFavourite = selectedProduct.isFavourite;
    _products[selectedProductIndex] = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavourite: !isFavourite);
    notifyListeners();
  }

  void selectProduct(int index) {
    _selProdIndex = index;
    if (index != null) {
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
  void login(String email, String password) {
    _authenticatedUser = User(id: 'asd', email: email, password: password);
  }
}

mixin UtilityScopedModel on ConnectedProdScopedModel {
  bool get isLoading {
    return _isLoading;
  }
}
