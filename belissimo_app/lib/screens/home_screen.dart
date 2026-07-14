import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/product.dart';
import '../state/app_state.provider.dart';
import 'product_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'name': 'Barchasi'},
    {'id': 'tortlar', 'name': 'Tortlar'},
    {'id': 'shirinliklar', 'name': 'Shirinliklar'},
    {'id': 'fastfood', 'name': 'Fastfood'},
    {'id': 'ichimliklar', 'name': 'Ichimliklar'},
    {'id': 'aksiyalar', 'name': 'Aksiyalar'},
  ];

  final List<String> _navoiyLocations = [
    'Navoiy shahri, Navoiy',
    'Karmana, Navoiy',
    'Qiziltepa, Navoiy',
    'Xatirchi, Navoiy',
    'Navbahor, Navoiy',
    'Konimex, Navoiy',
    'Nurota, Navoiy',
    'Tomdi, Navoiy',
    'Uchquduq, Navoiy',
    'Zarafshon, Navoiy',
  ];

  void _showLocationPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLarge)),
      ),
      builder: (context) {
        final appState = context.read<AppStateProvider>();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'Yetkazib berish manzili',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const Divider(color: AppColors.borderColor),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _navoiyLocations.length,
                  itemBuilder: (context, index) {
                    final loc = _navoiyLocations[index];
                    final isActive = loc == appState.currentLocation;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Text(
                        loc.split(',')[0],
                        style: TextStyle(
                          color: isActive ? AppColors.pinkAccent : AppColors.textDark,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check_rounded, color: AppColors.pinkAccent)
                          : null,
                      onTap: () {
                        appState.setLocation(loc);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('📍 Manzil o\'zgartirildi: ${loc.split(',')[0]}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.darkPurple,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    
    // Filter logic
    final List<Product> filteredProducts = Product.defaultInventory.where((product) {
      // Category filter
      final matchesCategory = _selectedCategory == 'all' ||
          product.category == _selectedCategory ||
          (_selectedCategory == 'aksiyalar' && product.hasDiscount);

      // Search query filter
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: GestureDetector(
          onTap: () => _showLocationPicker(context),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.pinkAccent, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manzil',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    Text(
                      appState.currentLocation.split(',')[0],
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textDark, size: 18),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.darkPurple),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Hozircha bildirishnomalar yo\'q.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Search & Banner header section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.bgGray,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Nima buyurtma qilmoqchisiz?',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // Banner Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkPurple.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: Image.asset(
                  'assets/images/banner.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
                ),
              ),
            ),
          ),

          // Categories Horizontal Selector
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = cat['id'] == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        cat['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.pinkAccent,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : AppColors.borderColor,
                        ),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = cat['id']!;
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),

          // Product list Grid / ListView
          filteredProducts.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
                          SizedBox(height: 16),
                          Text(
                            'Mahsulot topilmadi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = filteredProducts[index];
                        final isFav = appState.isFavorite(product.id);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(color: AppColors.borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkPurple.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Image
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        width: double.infinity,
                                        child: Center(
                                          child: Hero(
                                            tag: 'product-img-${product.id}',
                                            child: Image.asset(
                                              product.imageAsset,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Info
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Category & Rating Row
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                product.category == 'tortlar'
                                                    ? 'Tortlar'
                                                    : product.category == 'fastfood'
                                                        ? 'Fastfood'
                                                        : 'Shirinliklar',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded,
                                                      color: AppColors.gold, size: 14),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    '${product.rating}',
                                                    style: const TextStyle(
                                                      color: AppColors.textDark,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // Title
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkPurple,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          // Bottom Row (Price & Add Button)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  Formatters.formatSum(product.basePrice),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.pinkAccent,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  // Quick add: default size standard (or first if size options exist), empty extras, quantity 1
                                                  final defaultSize = product.sizes.isNotEmpty
                                                      ? product.sizes.firstWhere((s) => s.priceOffset == 0, orElse: () => product.sizes.first).value
                                                      : 'Standard';
                                                  final defaultPrice = product.sizes.isNotEmpty
                                                      ? product.basePrice + product.sizes.firstWhere((s) => s.priceOffset == 0, orElse: () => product.sizes.first).priceOffset
                                                      : product.basePrice;
                                                  
                                                  appState.addToCart(product, defaultPrice, 1, defaultSize, []);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('${product.name} savatchaga qo\'shildi! 🛒'),
                                                      behavior: SnackBarBehavior.floating,
                                                      duration: const Duration(seconds: 2),
                                                      backgroundColor: AppColors.pinkAccent,
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: 28,
                                                  height: 28,
                                                  decoration: const BoxDecoration(
                                                    color: AppColors.bgGray,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.add_rounded,
                                                    color: AppColors.darkPurple,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // Favorite Badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => appState.toggleFavorite(product.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Icon(
                                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                        color: isFav ? AppColors.pinkAccent : AppColors.textMuted,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: filteredProducts.length,
                    ),
                  ),
                ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }
}
