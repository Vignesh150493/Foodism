import 'package:scoped_model/scoped_model.dart';
import '../models/product.dart';

class ProductsScopedModel extends Model {
  List<Product> _products = [];
  int _selectedProdIndex;

  List<Product> get products {
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
  }

  void updateProduct(Product product) {
    _products[_selectedProdIndex] = product;
    _selectedProdIndex = null;
  }

  void deleteProduct() {
    _products.removeAt(_selectedProdIndex);
    _selectedProdIndex = null;
  }

  void selectProduct(int index) {
    _selectedProdIndex = index;
  }
}
