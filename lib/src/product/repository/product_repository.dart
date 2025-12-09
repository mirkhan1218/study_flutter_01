import 'package:bamtol_market_app/src/common/model/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductRepository extends GetxService {
  late CollectionReference products;

  ProductRepository(FirebaseFirestore db) {
    products = db.collection("products");
  }

  Future<String?> saveProduct(Map<String, dynamic> data) async {
    try {
      var docs = await products.add(data);
      return docs.id;
    } catch (e) {
      return null;
    }
  }

  Future<({List<Product> list, QueryDocumentSnapshot<Object?>? lastItem})>
  getProducts() async {
    try {
      QuerySnapshot<Object?> snapshot = await products.get();
      if (snapshot.docs.isNotEmpty) {
        return (
          list: snapshot.docs.map<Product>((product) {
            return Product.fromJson(
              product.id,
              product.data() as Map<String, dynamic>,
            );
          }).toList(),
          lastItem: snapshot.docs.last,
        );
      }
      return (list: <Product>[], lastItem: null);
    } catch (e) {
      print(e);
      return (list: <Product>[], lastItem: null);
    }
  }
}
