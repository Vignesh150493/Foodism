import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';
import '../models/user.dart';

class ConnectedProdScopedModel extends Model {
  List<Product> _products = [];
  int _selProdIndex;
  User _authenticatedUser;

  void addProduct(
      String title, String description, String image, double price) {
    final Product newProduct = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products.add(newProduct);
    notifyListeners();
  }
}

class ProductsScopedModel extends ConnectedProdScopedModel {
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

  void updateProduct(
      String title, String description, String image, double price) {
    _products[_selProdIndex] = Product(
        title: title,
        description: description,
        price: price,
        image: image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selProdIndex);
    notifyListeners();
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

class UserScopedModel extends ConnectedProdScopedModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'asd', email: email, password: password);
  }
}
