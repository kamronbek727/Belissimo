import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../models/product.dart';
import '../state/app_state.provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _MainBuyButtonContent extends StatelessWidget {
  final bool isAdded;

  const _MainBuyButtonContent({required this.isAdded});

  @override
  Widget build(BuildContext context) {
    if (isAdded) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_rounded, color: Colors.white, size: 20),
          SizedBox(width: 8),
          Text(
            'Qo\'shildi!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      );
    }
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
        SizedBox(width: 8),
        Text(
          'Savatchaga qo\'shish',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  ProductSizeOption? _selectedSize;
  bool _isAddedSuccessfully = false;

  @override
  void initState() {
    super.initState();
    // Default size is the one with 0 priceOffset, or the first size option
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.firstWhere(
        (s) => s.priceOffset == 0,
        orElse: () => widget.product.sizes.first,
      );
    }
  }

  int get _unitPrice {
    final sizeOffset = _selectedSize?.priceOffset ?? 0;
    return widget.product.basePrice + sizeOffset;
  }

  int get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final isFav = appState.isFavorite(widget.product.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkPurple, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Favorite
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? AppColors.pinkAccent : AppColors.textMuted,
            ),
            onPressed: () => appState.toggleFavorite(widget.product.id),
          ),
          // Share
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textMuted),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'https://github.com/kamronbek727/Belissimo/product/${widget.product.id}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Havola nusxalandi! 🔗'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.darkPurple,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image visual container
                  Container(
                    width: double.infinity,
                    height: 260,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.bgGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'product-img-${widget.product.id}',
                        child: Image.asset(
                          widget.product.imageAsset,
                          fit: BoxFit.contain,
                          width: 220,
                          height: 220,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detail metadata card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkPurple,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.bgGray,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderColor),
                              ),
                              child: Text(
                                widget.product.category == 'tortlar'
                                    ? 'Tortlar'
                                    : widget.product.category == 'fastfood'
                                        ? 'Fastfood'
                                        : 'Shirinliklar',
                                style: const TextStyle(
                                  color: AppColors.darkPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),

                        // Ratings row
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product.rating}',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.product.reviewCount} ta fikr)',
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Size options section if present
                        if (widget.product.sizes.isNotEmpty) ...[
                          const Text(
                            'O\'lcham',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkPurple,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1.3,
                            ),
                            itemCount: widget.product.sizes.length,
                            itemBuilder: (context, index) {
                              final size = widget.product.sizes[index];
                              final isSelected = _selectedSize?.value == size.value;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedSize = size;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.darkPurple : Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : AppColors.borderColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        size.value,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected ? Colors.white : AppColors.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        size.desc,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? Colors.white.withOpacity(0.7)
                                              : AppColors.textMuted,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Purchase actions bar
          Container(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderColor.withOpacity(0.6), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Jami narx',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.15),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        Formatters.formatSum(_totalPrice),
                        key: ValueKey<int>(_totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.pinkAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Quantity selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.bgGray,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          children: [
                            Opacity(
                              opacity: _quantity <= 1 ? 0.35 : 1.0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_rounded, color: AppColors.darkPurple, size: 20),
                                onPressed: _quantity <= 1
                                    ? null
                                    : () {
                                        setState(() {
                                          _quantity--;
                                        });
                                      },
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 24),
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_rounded, color: AppColors.darkPurple, size: 20),
                              onPressed: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Add to Cart Button
                      Expanded(
                        child: GestureDetector(
                          onTap: _isAddedSuccessfully
                              ? null
                              : () {
                                  appState.addToCart(
                                    widget.product,
                                    _unitPrice,
                                    _quantity,
                                    _selectedSize?.value ?? 'Standard',
                                    [],
                                  );
                                  
                                  setState(() {
                                    _isAddedSuccessfully = true;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Savatchaga qo\'shildi! ($_quantity ta) 🛒'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: AppColors.pinkAccent,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  Future.delayed(const Duration(milliseconds: 1500), () {
                                    if (mounted) {
                                      setState(() {
                                        _isAddedSuccessfully = false;
                                      });
                                    }
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: _isAddedSuccessfully ? null : AppColors.pinkGradient,
                              color: _isAddedSuccessfully ? const Color(0xFF2ecc71) : null,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                if (!_isAddedSuccessfully)
                                  BoxShadow(
                                    color: AppColors.pinkAccent.withOpacity(0.25),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: _MainBuyButtonContent(isAdded: _isAddedSuccessfully),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
