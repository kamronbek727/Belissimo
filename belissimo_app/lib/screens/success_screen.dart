import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/app_state.provider.dart';
import 'main_navigation.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final order = appState.latestOrder;

    final orderId = order?.id ?? '#BL000000';
    final dateStr = order?.date ?? '--.--.----';
    final paymentLabel = order != null 
        ? (order.paymentMethod == 'card' ? 'Karta orqali' : 'Naqd pul')
        : '--';

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Green success check icon card
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ecc71).withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2ecc71).withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF2ecc71),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Header
                const Text(
                  'Buyurtmangiz qabul qilindi! 🎉',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkPurple,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Description
                const Text(
                  'Kuryerimiz tez orada siz bilan bog\'lanadi va mazali taomlaringizni yetkazib beradi!',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Order Info Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.darkPurple.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Buyurtma raqami:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            orderId,
                            style: const TextStyle(color: AppColors.darkPurple, fontSize: 14, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sana:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            dateStr,
                            style: const TextStyle(color: AppColors.darkPurple, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'To\'lov usuli:',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            paymentLabel,
                            style: const TextStyle(color: AppColors.darkPurple, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Action Buttons
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to Orders Tab in Shell (which is tab index 2)
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainNavigationShell(),
                              settings: const RouteSettings(name: '/'),
                            ),
                            (route) => false,
                          );
                          // We need to trigger tab switch if needed. We can handle it simple or define main nav shell with default index.
                          // To switch cleanly, let's allow setting target index, or since the home screen will reset, they can just click the Orders tab.
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
                            'Buyurtmani kuzatish',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainNavigationShell()),
                            (route) => false,
                          );
                        },
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Asosiy sahifaga qaytish',
                            style: TextStyle(
                              color: AppColors.darkPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
