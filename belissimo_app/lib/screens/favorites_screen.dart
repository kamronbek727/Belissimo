import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/product.dart';
import '../state/app_state.provider.dart';
import 'product_detail.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final favIds = appState.favorites;

    // Filter products from inventory
    final List<Product> favProducts = Product.defaultInventory
        .where((p) => favIds.contains(p.id))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Sevimlilar'),
      ),
      body: favProducts.isEmpty
          ? _buildEmptyFavorites(context)
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: favProducts.length,
              itemBuilder: (context, index) {
                final product = favProducts[index];
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
                                  child: Image.asset(
                                    product.imageAsset,
                                    fit: BoxFit.contain,
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
            ),
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.pinkAccent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                color: AppColors.pinkAccent,
                size: 72,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sizda hozircha saralangan mahsulotlar mavjud emas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
