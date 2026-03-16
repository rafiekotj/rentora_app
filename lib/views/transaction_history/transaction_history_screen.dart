import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';
import 'package:rentora_app/widgets/custom_button.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  static const List<String> _tabTitles = [
    'Semua',
    'Belum Bayar',
    'Diproses',
    'Sedang Disewa',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabTitles.length,
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: AppBar(
          toolbarHeight: 58,
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.textOnPrimary,
          title: Text(
            "Riwayat Transaksi",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Symbols.chat, weight: 600)),
            SizedBox(width: 8),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColor.surface,
            labelColor: AppColor.surface,
            unselectedLabelColor: AppColor.textOnPrimary.withAlpha(170),
            tabs: _tabTitles.map((title) => Tab(text: title)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabTitles
              .map(
                (status) => SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColor.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text("Nama Toko"), Text(status)],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColor.border,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: SizedBox(
                                      height: 80,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text("Nama Produk"),
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text("x2"),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Text("Rp100.000"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Pinjam 2 hari: "),
                                    Text(
                                      "Rp100.000",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              Align(
                                alignment: Alignment.bottomRight,
                                child: CustomButton(
                                  width: 88,
                                  height: 36,
                                  isOutlined: true,
                                  text: "Beri Nilai",
                                  borderColor: AppColor.primary,
                                  textColor: AppColor.primary,
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
