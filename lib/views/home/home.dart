import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rentora_app/utils/constant/app_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<CategoryItem> categories = const [
    CategoryItem(
      label: "Elektronik",
      icon: Symbols.speaker,
      color: Color(0xff98A1BC),
    ),
    CategoryItem(
      label: "Pakaian",
      icon: Symbols.apparel,
      color: Color(0xffFF9B51),
    ),
    CategoryItem(
      label: "Sepatu",
      icon: Symbols.shoe_cleats,
      color: Color(0xff578FCA),
    ),
    CategoryItem(
      label: "Tas",
      icon: Symbols.backpack,
      color: Color(0xffF16727),
    ),
    CategoryItem(
      label: "Furniture",
      icon: Symbols.chair,
      color: Color(0xffFACC15),
    ),
    CategoryItem(label: "Buku", icon: Symbols.book_2, color: Color(0xffE2B59A)),
    CategoryItem(
      label: "Hobi",
      icon: Symbols.stadia_controller,
      color: Color(0xff758A93),
    ),
    CategoryItem(
      label: "Otomotif",
      icon: Symbols.search_hands_free,
      color: Color(0xffBBDCE5),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: AppBar(
        toolbarHeight: 58,
        backgroundColor: AppColor.primary,
        titleSpacing: 0,
        automaticallyImplyLeading: false,
        title: Container(
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColor.textOnPrimary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const TextField(
                    cursorColor: AppColor.textSecondary,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: "Search",
                      hintStyle: TextStyle(color: AppColor.textSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColor.textSecondary,
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColor.textOnPrimary,
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.shopping_cart_outlined,
                color: AppColor.textOnPrimary,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Kategori",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                mainAxisExtent: 106,
              ),
              itemBuilder: (context, index) {
                final item = categories[index];

                return CategoryItem(
                  label: item.label,
                  icon: item.icon,
                  color: item.color,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const CategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
            ),
            child: Center(child: Icon(icon, color: color, size: 28)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
