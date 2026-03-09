import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/core/constants/app_color.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        foregroundColor: AppColor.textOnPrimary,
        title: Text(
          "Keranjang",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Symbols.chat, weight: 600)),

          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 8, right: 8, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  /// HEADER STORE
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        activeColor: AppColor.primary,
                        onChanged: (value) {},
                      ),
                      Text(
                        "Big Cam Store",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacer(),

                      Container(
                        height: 28,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.border),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColor.border,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                onPressed: () {},
                                icon: Icon(Icons.remove),
                              ),
                            ),
                            SizedBox(width: 4),
                            Text("2 hari", style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColor.border,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(4),
                                  bottomRight: Radius.circular(4),
                                ),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                iconSize: 16,
                                onPressed: () {},
                                icon: Icon(Icons.add),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  /// ITEM 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: true,
                        activeColor: AppColor.primary,
                        onChanged: (value) {},
                      ),

                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColor.border),
                        ),
                        child: Container(),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kamera Canon EOS 1000",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 6),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              height: 28,
                              width: 112,
                              decoration: BoxDecoration(
                                color: AppColor.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton(
                                value: "1 buah",
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: AppColor.backgroundLight,
                                iconSize: 16,
                                items: [
                                  DropdownMenuItem(
                                    value: "1 buah",
                                    child: Text(
                                      "1 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "2 buah",
                                    child: Text(
                                      "2 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "3 buah",
                                    child: Text(
                                      "3 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {},
                              ),
                            ),

                            SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  "Rp80.000",
                                  style: TextStyle(
                                    color: AppColor.secondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "/hari",
                                  style: TextStyle(
                                    color: AppColor.textHint,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12),

                  /// ITEM 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: true,
                        activeColor: AppColor.primary,
                        onChanged: (value) {},
                      ),

                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Container(),
                      ),

                      SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Kamera Canon EOS 1000",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            SizedBox(height: 6),

                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              height: 28,
                              width: 112,
                              decoration: BoxDecoration(
                                color: AppColor.border,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: DropdownButton(
                                value: "1 buah",
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: AppColor.backgroundLight,
                                iconSize: 16,
                                items: [
                                  DropdownMenuItem(
                                    value: "1 buah",
                                    child: Text(
                                      "1 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "2 buah",
                                    child: Text(
                                      "2 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: "3 buah",
                                    child: Text(
                                      "3 buah",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {},
                              ),
                            ),

                            SizedBox(height: 6),

                            Row(
                              children: [
                                Text(
                                  "Rp60.000",
                                  style: TextStyle(
                                    color: AppColor.secondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "/hari",
                                  style: TextStyle(
                                    color: AppColor.textHint,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(8),
        height: 56,
        color: AppColor.textOnPrimary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Rp 440.000",
              style: TextStyle(
                color: AppColor.secondary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(width: 16),

            GestureDetector(
              onTap: () {},
              child: Container(
                width: 120,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "Sewa",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
