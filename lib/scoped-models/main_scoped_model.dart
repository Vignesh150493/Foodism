import 'package:scoped_model/scoped_model.dart';
import 'connected_prod_scoped_model.dart';

class MainScopedModel extends Model
    with ConnectedProdScopedModel, UserScopedModel, ProductsScopedModel, UtilityScopedModel {}
