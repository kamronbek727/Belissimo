import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/formatters.dart';
import '../state/app_state.provider.dart';
import 'success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Switch state
  String _deliveryMethod = 'delivery'; // 'delivery' or 'pickup'
  String _paymentMethod = 'cash'; // 'cash' or 'card'

  // Form keys and controllers
  final _formKey = GlobalKey<FormState>();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  
  // Card payment controllers
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();

  // Delivery Address/Map States
  double _latitude = 40.1039;
  double _longitude = 65.3739;
  String _selectedAddressStr = 'Navoiy shahri, Tinchlik ko\'chasi, 12-uy';
  bool _isAddressConfirmed = false;
  bool _isLocatingUser = false;
  final TextEditingController _mapSearchController = TextEditingController();

  final List<Map<String, dynamic>> _mockNavoiyAddresses = [
    {
      'address': 'Navoiy shahri, Navoiy ko\'chasi, 32-uy',
      'lat': 40.1039,
      'lng': 65.3739
    },
    {
      'address': 'Karmana, Ibn Sino ko\'chasi, 14-uy',
      'lat': 40.1384,
      'lng': 65.3644
    },
    {
      'address': 'Navoiy shahri, G\'alaba shoh ko\'chasi, 5-uy',
      'lat': 40.1005,
      'lng': 65.3780
    },
    {
      'address': 'Navoiy shahri, Tinchlik ko\'chasi, 45-uy',
      'lat': 40.1062,
      'lng': 65.3688
    },
  ];

  @override
  void initState() {
    super.initState();
    // Default location coords based on selected region
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppStateProvider>();
      final area = appState.currentLocation.split(',')[0].trim().toLowerCase();
      if (area == 'karmana') {
        _latitude = 40.1384;
        _longitude = 65.3644;
        _selectedAddressStr = 'Karmana, Ibn Sino ko\'chasi, 14-uy';
      } else if (area == 'qiziltepa') {
        _latitude = 40.0163;
        _longitude = 64.8456;
        _selectedAddressStr = 'Qiziltepa, Toshkent yo\'li, 3-uy';
      } else {
        _latitude = 40.1039;
        _longitude = 65.3739;
        _selectedAddressStr = '${appState.currentLocation.split(',')[0]}, Tinchlik ko\'chasi, 12-uy';
      }
      setState(() {});
    });

    // Formatting listeners
    _guestPhoneController.addListener(_formatPhoneInput);
    _cardNumberController.addListener(_formatCardNumberInput);
    _cardExpiryController.addListener(_formatCardExpiryInput);
    _cardCvvController.addListener(_formatCardCvvInput);
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _mapSearchController.dispose();
    super.dispose();
  }

  // --- Input Formatters ---
  void _formatPhoneInput() {
    String text = _guestPhoneController.text;
    if (!text.startsWith('+998 ')) {
      text = '+998 ' + text.replaceAll(RegExp(r'^\+?9?9?8?\s?'), '');
    }
    String digits = text.substring(5).replaceAll(RegExp(r'\D'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    
    String formatted = '';
    if (digits.isNotEmpty) formatted += digits.substring(0, min(2, digits.length));
    if (digits.length > 2) formatted += ' ' + digits.substring(2, min(5, digits.length));
    if (digits.length > 5) formatted += ' ' + digits.substring(5, min(7, digits.length));
    if (digits.length > 7) formatted += ' ' + digits.substring(7, min(9, digits.length));

    final newText = '+998 ' + formatted;
    if (_guestPhoneController.text != newText) {
      _guestPhoneController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
      );
    }
  }

  void _formatCardNumberInput() {
    String val = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    if (val.length > 16) val = val.substring(0, 16);
    
    final buffer = StringBuffer();
    for (int i = 0; i < val.length; i++) {
      buffer.write(val[i]);
      final index = i + 1;
      if (index % 4 == 0 && index != val.length) {
        buffer.write(' ');
      }
    }
    final formatted = buffer.toString();
    if (_cardNumberController.text != formatted) {
      _cardNumberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.fromPosition(TextPosition(offset: formatted.length)),
      );
    }
  }

  void _formatCardExpiryInput() {
    String val = _cardExpiryController.text.replaceAll(RegExp(r'\D'), '');
    if (val.length > 4) val = val.substring(0, 4);
    
    String formatted = val;
    if (val.length > 2) {
      formatted = val.substring(0, 2) + '/' + val.substring(2);
    }
    if (_cardExpiryController.text != formatted) {
      _cardExpiryController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.fromPosition(TextPosition(offset: formatted.length)),
      );
    }
  }

  void _formatCardCvvInput() {
    String val = _cardCvvController.text.replaceAll(RegExp(r'\D'), '');
    if (val.length > 3) val = val.substring(0, 3);
    if (_cardCvvController.text != val) {
      _cardCvvController.value = TextEditingValue(
        text: val,
        selection: TextSelection.fromPosition(TextPosition(offset: val.length)),
      );
    }
  }

  // --- Map Simulation Controls ---
  void _simulateLocateUser() {
    setState(() {
      _isLocatingUser = true;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLocatingUser = false;
          _latitude = 40.1039 + (Random().nextDouble() - 0.5) * 0.02;
          _longitude = 65.3739 + (Random().nextDouble() - 0.5) * 0.02;
          _selectedAddressStr = 'Navoiy shahri, Tanlangan nuqta (Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)})';
          _isAddressConfirmed = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joylashuv aniqlandi! 📍'), behavior: SnackBarBehavior.floating),
        );
      }
    });
  }

  void _searchAddressOnMap(String query) {
    if (query.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    
    // Simulate address lookup
    final matched = _mockNavoiyAddresses.firstWhere(
      (addr) => addr['address'].toLowerCase().contains(query.toLowerCase()),
      orElse: () => {
        'address': '$query, Navoiy shahri, Navoiy viloyati',
        'lat': 40.1039 + (Random().nextDouble() - 0.5) * 0.01,
        'lng': 65.3739 + (Random().nextDouble() - 0.5) * 0.01,
      },
    );

    setState(() {
      _selectedAddressStr = matched['address'];
      _latitude = matched['lat'];
      _longitude = matched['lng'];
      _isAddressConfirmed = false;
    });
  }

  void _onConfirmOrder() async {
    final appState = context.read<AppStateProvider>();
    
    // 1. Validate Guest Info if guest
    String finalName = '';
    String finalPhone = '';
    
    if (!appState.isLoggedIn) {
      if (_guestNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iltimos, ismingizni kiriting! 👤'), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      if (_guestPhoneController.text.length < 17) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Iltimos, telefon raqamingizni to\'liq kiriting! 📱'), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      finalName = _guestNameController.text.trim();
      finalPhone = _guestPhoneController.text.trim();
    } else {
      finalName = appState.userName;
      finalPhone = appState.userPhone;
    }

    // 2. Validate Delivery Address
    if (_deliveryMethod == 'delivery') {
      if (!_isAddressConfirmed) {
        // Auto confirm address
        _isAddressConfirmed = true;
      }
    }

    // 3. Validate Card Details
    if (_paymentMethod == 'card') {
      final cNum = _cardNumberController.text.replaceAll(' ', '');
      final cExp = _cardExpiryController.text;
      final cCvv = _cardCvvController.text;

      if (cNum.length < 16) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karta raqamini to\'g\'ri kiriting! 💳'), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      if (cExp.length < 5 || !cExp.contains('/')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karta amal qilish muddatini kiriting! 📅'), behavior: SnackBarBehavior.floating),
        );
        return;
      }
      if (cCvv.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karta CVV kodini kiriting! 🔒'), behavior: SnackBarBehavior.floating),
        );
        return;
      }
    }

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.pinkAccent),
      ),
    );

    // Save Guest user details temporary in AppState for the order
    if (!appState.isLoggedIn) {
      appState.login(finalName, finalPhone);
    }

    // Process order
    final success = await appState.createOrder(
      deliveryType: _deliveryMethod,
      paymentMethod: _paymentMethod,
      address: _deliveryMethod == 'delivery' ? _selectedAddressStr : null,
      latitude: _deliveryMethod == 'delivery' ? _latitude : null,
      longitude: _deliveryMethod == 'delivery' ? _longitude : null,
      branch: _deliveryMethod == 'pickup' ? 'Bellissimo Navoiy filiali' : null,
      subtotalValue: appState.cartSubtotal,
      deliveryFeeValue: _deliveryMethod == 'pickup' ? 0 : appState.deliveryFee,
      totalStr: Formatters.formatSum(_deliveryMethod == 'pickup' ? appState.cartSubtotal : appState.cartTotal),
    );

    // Close Loading
    if (mounted) Navigator.pop(context);

    if (success) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buyurtma yaratishda xatolik yuz berdi! ❌'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final cartItems = appState.cart;

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkPurple, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Rasmiylashtirish'),
      ),
      body: cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Delivery Switch TabBar Style
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _deliveryMethod = 'delivery';
                                      });
                                    },
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _deliveryMethod == 'delivery' ? AppColors.darkPurple : Colors.transparent,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Yetkazib berish',
                                        style: TextStyle(
                                          color: _deliveryMethod == 'delivery' ? Colors.white : AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _deliveryMethod = 'pickup';
                                      });
                                    },
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: _deliveryMethod == 'pickup' ? AppColors.darkPurple : Colors.transparent,
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Olib ketish',
                                        style: TextStyle(
                                          color: _deliveryMethod == 'pickup' ? Colors.white : AppColors.textMuted,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),

                          // 2. Customer Information Card
                          appState.isLoggedIn
                              ? Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    border: Border.all(color: AppColors.borderColor),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mijoz ma\'lumotlari',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkPurple),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        appState.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        appState.userPhone,
                                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                                    border: Border.all(color: AppColors.borderColor),
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mijoz ma\'lumotlari',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkPurple),
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _guestNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Ism',
                                          hintText: 'Ismingizni kiriting',
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _guestPhoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                          labelText: 'Telefon raqami',
                                          hintText: '+998 XX XXX XX XX',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                          const SizedBox(height: 24),

                          // 3. Delivery Method Specific Section
                          _deliveryMethod == 'delivery'
                              ? _buildMapSection(context)
                              : _buildPickupSection(context),

                          const SizedBox(height: 24),

                          // 4. Payment Method Card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'To\'lov usuli',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkPurple),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _paymentMethod = 'cash';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            border: Border.all(
                                              color: _paymentMethod == 'cash' ? AppColors.pinkAccent : AppColors.borderColor,
                                              width: _paymentMethod == 'cash' ? 2 : 1.5,
                                            ),
                                          ),
                                          child: const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Naqd pul',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkPurple),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Kuryerga to\'lash',
                                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _paymentMethod = 'card';
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                            border: Border.all(
                                              color: _paymentMethod == 'card' ? AppColors.pinkAccent : AppColors.borderColor,
                                              width: _paymentMethod == 'card' ? 2 : 1.5,
                                            ),
                                          ),
                                          child: const Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Karta orqali',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.darkPurple),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Onlayn to\'lov',
                                                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Online card entry fields
                                if (_paymentMethod == 'card') ...[
                                  const SizedBox(height: 20),
                                  const Divider(color: AppColors.borderColor),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Karta ma\'lumotlari',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.darkPurple),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _cardNumberController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Karta raqami',
                                      hintText: '8600 **** **** ****',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cardExpiryController,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(
                                            labelText: 'Muddati',
                                            hintText: 'OO/YY',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _cardCvvController,
                                          keyboardType: TextInputType.number,
                                          obscureText: true,
                                          decoration: const InputDecoration(
                                            labelText: 'CVV/CVC',
                                            hintText: '***',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.bgGray,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                      border: Border.all(color: AppColors.borderColor),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.lock_outline_rounded, color: Colors.green, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Karta ma\'lumotlari saqlanmaydi va to\'lov xavfsiz shifrlangan ulanish orqali amalga oshiriladi.',
                                            style: TextStyle(color: AppColors.textMuted, fontSize: 11, height: 1.3),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ]
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Summary & Place Order Button
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
                                'Mahsulotlar:',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                Formatters.formatSum(appState.cartSubtotal),
                                style: const TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Yetkazib berish:',
                                style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                _deliveryMethod == 'pickup'
                                    ? 'Bepul'
                                    : (appState.deliveryFee == 0 ? 'Bepul' : Formatters.formatSum(appState.deliveryFee)),
                                style: TextStyle(
                                  color: (_deliveryMethod == 'pickup' || appState.deliveryFee == 0)
                                      ? Colors.green
                                      : AppColors.textDark,
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
                                'Jami:',
                                style: TextStyle(color: AppColors.darkPurple, fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                              Text(
                                Formatters.formatSum(_deliveryMethod == 'pickup' ? appState.cartSubtotal : appState.cartTotal),
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
                            onTap: _onConfirmOrder,
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
                                'Buyurtmani tasdiqlash',
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
            ),
    );
  }

  Widget _buildMapSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yetkazib berish manzili',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkPurple),
          ),
          const SizedBox(height: 16),
          // Search Row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgGray,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _mapSearchController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _searchAddressOnMap,
                          decoration: const InputDecoration(
                            hintText: 'Manzilni qidiring...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _simulateLocateUser,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.bgGray,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: _isLocatingUser
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.pinkAccent),
                        )
                      : const Icon(Icons.my_location_rounded, color: AppColors.darkPurple, size: 20),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          // Map interface simulation card
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E3DF),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Stack(
              children: [
                // Mock grid lines representing a map
                Positioned.fill(
                  child: GridPaper(
                    color: Colors.blue.withOpacity(0.04),
                    divisions: 1,
                    subdivisions: 1,
                    interval: 60,
                  ),
                ),
                // Mock streets/buildings lines representation
                Positioned(
                  left: 30, top: 40, right: 30,
                  child: Divider(color: Colors.white.withOpacity(0.6), thickness: 6),
                ),
                Positioned(
                  left: 80, top: 0, bottom: 0,
                  child: VerticalDivider(color: Colors.white.withOpacity(0.6), thickness: 8),
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24), // Offset for pin point
                    child: Icon(
                      Icons.location_on_rounded,
                      color: AppColors.pinkAccent,
                      size: 36,
                    ),
                  ),
                ),
                // Info coordinate panel
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkPurple.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Lat: ${_latitude.toStringAsFixed(4)}, Lng: ${_longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          // Address text box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TANLANGAN MANZIL',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.pinkAccent, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedAddressStr,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkPurple),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          // Confirm address button
          GestureDetector(
            onTap: () {
              setState(() {
                _isAddressConfirmed = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manzil muvaffaqiyatli tasdiqlandi! ✓'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
              );
            },
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _isAddressConfirmed ? const Color(0xFF2ecc71) : AppColors.darkPurple,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Text(
                _isAddressConfirmed ? 'Tasdiqlandi ✓' : 'Manzilni tasdiqlash',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPickupSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppColors.borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Olib ketish joyi',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.darkPurple),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgGray,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.borderColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pinkAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.pinkAccent, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bellissimo Navoiy filiali',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkPurple),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Navoiy shahri, Navoiy ko\'chasi, 32-uy (Markaziy universal do\'koni yonida)',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Buyurtmangiz tayyor bo\'lganda filialdan olib ketishingiz mumkin.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
