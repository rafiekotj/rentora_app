import 'package:rentora_app/controllers/store_controller.dart';
import 'package:rentora_app/models/product_model.dart';
import 'package:rentora_app/services/database/product_service.dart';

class ProductController {
  final _storeController = StoreController();
  final _productService = ProductService();

  Future<String> addProduct(ProductModel product) async {
    // Tambah produk baru
    return await _productService.addProduct(product);
  }

  Future<void> updateProduct(String productId, ProductModel product) async {
    // Update data produk
    await _productService.updateProduct(productId, product);
  }

  Future<void> deleteProduct(String productId) async {
    // Hapus produk
    await _productService.deleteProduct(productId);
  }

  Future<List<ProductModel>> getMyProducts() async {
    // Ambil produk milik store user
    final store = await _storeController.getStore();
    if (store == null) {
      // Jika belum punya store, kembalikan list kosong
      return [];
    }
    return await _productService.getProductsByStore(store.uid);
  }

  Future<List<ProductModel>> getProductByKategori(String kategori) async {
    // Ambil produk berdasarkan kategori
    return await _productService.getProductByKategori(kategori);
  }

  Future<List<ProductModel>> getAllProduct() async {
    // Ambil semua produk
    return await _productService.getAllProduct();
  }

  Future<List<ProductModel>> searchProducts({
    String? query,
    String? district,
    String? priceOrder,
  }) async {
    // Ambil semua produk
    final all = await _productService.getAllProduct();
    var results = all;

    // Filter berdasarkan query pencarian
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((p) {
        final nama = p.namaProduk.toLowerCase();
        final des = p.deskripsiProduk.toLowerCase();
        final kat = p.kategori.toLowerCase();
        return nama.contains(q) || des.contains(q) || kat.contains(q);
      }).toList();
    }

    // Filter berdasarkan district
    if (district != null && district.trim().isNotEmpty) {
      final storeUids = results
          .map((p) => p.storeUid)
          .whereType<String>()
          .toSet()
          .toList();
      final stores = await _storeController.getStoresByIds(storeUids);
      final storeDistrictMap = {for (var s in stores) s.uid: s.district ?? ''};
      results = results.where((p) {
        final sd = storeDistrictMap[p.storeUid]?.toLowerCase() ?? '';
        return sd == district.toLowerCase();
      }).toList();
    }

    // Urutkan berdasarkan harga jika diminta
    if (priceOrder != null && priceOrder.isNotEmpty) {
      if (priceOrder == 'asc') {
        results.sort((a, b) => a.hargaPerHari.compareTo(b.hargaPerHari));
      } else if (priceOrder == 'desc') {
        results.sort((a, b) => b.hargaPerHari.compareTo(a.hargaPerHari));
      }
    }

    return results;
  }
}
