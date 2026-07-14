import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme.dart';
import '../state/app_state.provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const Map<String, String> statusMap = {
    'new': 'Yangi',
    'accepted': 'Qabul qilindi',
    'cooking': 'Tayyorlanmoqda',
    'preparing': 'Tayyorlanmoqda',
    'ready': 'Tayyor',
    'courier_assigned': 'Kuryer tayinlangan',
    'on_the_way': 'Yo\'lda',
    'delivered': 'Yetkazib berildi',
    'cancelled': 'Bekor qilindi',
  };

  static const Map<String, Color> statusColors = {
    'new': Color(0xFF3498db),
    'accepted': Color(0xFF2ecc71),
    'cooking': Color(0xFFf1c40f),
    'preparing': Color(0xFFf1c40f),
    'ready': Color(0xFF9b59b6),
    'courier_assigned': Color(0xFF16a085),
    'on_the_way': Color(0xFFe67e22),
    'delivered': Color(0xFF27ae60),
    'cancelled': Color(0xFFe74c3c),
  };

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final orders = appState.orders;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Buyurtmalar'),
      ),
      body: orders.isEmpty
          ? _buildEmptyOrders(context)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final statusText = statusMap[order.status] ?? order.status;
                final statusColor = statusColors[order.status] ?? AppColors.textMuted;

                final itemsText = order.items
                    .map((item) => '${item.name} (${item.quantity}x)')
                    .join(', ');

                final deliveryLabel = order.deliveryType == 'pickup' ? 'Olib ketish' : 'Yetkazib berish';
                final paymentLabel = order.paymentMethod == 'card' ? 'Karta orqali' : 'Naqd pul';
                
                final locationDetail = order.deliveryType == 'pickup'
                    ? (order.branch ?? 'Bellissimo Navoiy filiali')
                    : (order.address ?? 'Kiritilmagan');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: ID, Date and Status tag
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: AppColors.darkPurple,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.date,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderColor),
                      const SizedBox(height: 10),
                      
                      // Details Fields
                      _buildDetailRow('Taomlar:', itemsText),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Yetkazib berish:',
                        '$deliveryLabel ($locationDetail)',
                        isHtml: order.deliveryType == 'delivery' && order.latitude != null,
                        lat: order.latitude,
                        lng: order.longitude,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('To\'lov usuli:', paymentLabel),
                      
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderColor, thickness: 1),
                      const SizedBox(height: 10),
                      
                      // Bottom Row: Total Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jami summa:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.darkPurple,
                            ),
                          ),
                          Text(
                            order.total,
                            style: const TextStyle(
                              color: AppColors.pinkAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHtml = false, double? lat, double? lng}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (isHtml && lat != null && lng != null) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () {
              // Open web view or launch map coordinate
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_outlined, color: AppColors.pinkAccent, size: 14),
                SizedBox(width: 4),
                Text(
                  'Xaritada ko\'rish',
                  style: TextStyle(
                    color: AppColors.pinkAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          )
        ]
      ],
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
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
              'Sizda hozircha faol buyurtmalar mavjud emas',
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
