import 'package:bamtol_market_app/src/common/model/product.dart';
import 'package:bamtol_market_app/src/product/repository/product_repository.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  ProductRepository _productRepository;

  HomeController(this._productRepository);
  RxList<Product> productList = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadProductList();
  }

  Future<void> _loadProductList() async {
    var result = await _productRepository.getProducts();
    productList.addAll(result.list);
  }
}
