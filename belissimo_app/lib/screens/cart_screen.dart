import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../state/app_state.provider.dart';
import '../screens/main_navigation.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final cartItems = appState.cart;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Savatcha'),
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              child: Image.asset(
                                item.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Item info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkPurple,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.size,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Price & Controls Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Formatters.formatSum(item.total),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.pinkAccent,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgGray,
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(color: AppColors.borderColor),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, color: AppColors.darkPurple, size: 16),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                              onPressed: () => appState.changeCartQty(index, -1),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: AppColors.textDark,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              icon: const Icon(Icons.add, color: AppColors.darkPurple, size: 16),
                                              padding: EdgeInsets.zero,
                                              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
                                              onPressed: () => appState.changeCartQty(index, 1),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // Delete button
                            GestureDetector(
                              onTap: () {
                                appState.removeCartItem(index);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Mahsulot savatchadan olindi!'),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppColors.darkPurple,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Summary Panel
                Container(
                  padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.borderColor, width: 1.5),
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Taomlar narxi:',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              Formatters.formatSum(appState.cartSubtotal),
                              style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Yetkazib berish:',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              appState.deliveryFee == 0 ? 'Bepul' : Formatters.formatSum(appState.deliveryFee),
                              style: TextStyle(
                                color: appState.deliveryFee == 0 ? Colors.green : AppColors.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.borderColor, thickness: 1),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jami summa:',
                              style: TextStyle(color: AppColors.darkPurple, fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              Formatters.formatSum(appState.cartTotal),
                              style: const TextStyle(
                                color: AppColors.pinkAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: AppColors.pinkGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pinkAccent.withOpacity(0.25),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Buyurtma berish',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/korzinka.svg',
              width: 180,
              height: 180,
            ),
            const SizedBox(height: 24),
            const Text(
              'Savatchangiz hozircha bo\'sh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                // Navigate back to Home (Tab 0)
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainNavigationShell()),
                  (route) => false,
                );
              },
              child: Container(
                height: 48,
                width: 180,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Menyuni ko\'rish',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
