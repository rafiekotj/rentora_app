import 'package:flutter/material.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/order_products_card.dart';
import 'package:rentora_app/controllers/transaction_controller.dart';
import 'package:rentora_app/models/transaction_model.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen> {
  final TransactionController _transactionController = TransactionController();
  List<TransactionModel> _transactions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final store = await _transactionController.storeController.getStore();
      if (store == null) {
        setState(() {
          _error = 'Toko tidak ditemukan';
          _loading = false;
        });
        return;
      }

      final transactions = await _transactionController.transactionService
          .getTransactionsByStore(store.uid, [
            'Diproses',
            'Belum Bayar',
            'Dikirim',
            'Dikemas',
            'Selesai',
          ]);

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : RefreshIndicator(
                onRefresh: _loadTransactions,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _transactions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    return OrderProductsCard(
                      storeName: tx.storeName,
                      items: tx.items,
                      rentalDays: tx.rentalDays,
                    );
                  },
                ),
              ),
      ),
    );
  }
}
