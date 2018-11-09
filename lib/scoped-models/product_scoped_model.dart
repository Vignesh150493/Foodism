import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';

class ProductsScopedModel extends Model {
  List<Product> _products = [];
  int _selectedProdIndex;
  bool _showFavourites = false;

  List<Product> get products {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavourites) {
      return _products.where((Product product) => product.isFavourite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selectedProdIndex;
  }

  Product get selectedProduct {
    if (_selectedProdIndex == null) {
      return null;
    }
    return _products[_selectedProdIndex];
  }

  void addProduct(Product product) {
    _products.add(product);
    _selectedProdIndex = null;
    notifyListeners();
  }

  void updateProduct(Product product) {
    _products[_selectedProdIndex] = product;
    _selectedProdIndex = null;
    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(_selectedProdIndex);
    _selectedProdIndex = null;
    notifyListeners();
  }

  void toggleProductFavouriteStatus() {
    final bool isFavourite = selectedProduct.isFavourite;
    _products[selectedProductIndex] = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        isFavourite: !isFavourite);
    notifyListeners();
    _selectedProdIndex = null;
  }

  void selectProduct(int index) {
    _selectedProdIndex = index;
  }

  void toggleDisplayMode() {
    _showFavourites = !_showFavourites;
    notifyListeners();
  }

  bool displayFavouritesOnly() {
    return _showFavourites;
  }
}
