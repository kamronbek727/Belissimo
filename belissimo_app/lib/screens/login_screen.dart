import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../state/app_state.provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  int _step = 1; // 1: Phone input, 2: Name input
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_formatPhoneInput);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _formatPhoneInput() {
    String text = _phoneController.text;
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
    if (_phoneController.text != newText) {
      _phoneController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.fromPosition(TextPosition(offset: newText.length)),
      );
    }
  }

  void _onNextStep() {
    if (_phoneController.text.length < 17) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, telefon raqamingizni to\'liq kiriting! 📱'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _step = 2;
    });
  }

  void _onSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Iltimos, ismingizni kiriting! 👤'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final appState = context.read<AppStateProvider>();
    appState.login(name, _phoneController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tizimga muvaffaqiyatli kirildi! 🔓'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );

    // After success, we just pop or reload. 
    // The profile screen checks if logged in and renders details automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Kirish'),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo2.png',
                height: 100,
              ),
              const SizedBox(height: 40),

              // Steps Card
              Container(
                width: double.infinity,
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _step == 1 ? _buildPhoneStep() : _buildNameStep(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Telefon raqamingiz',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkPurple),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tizimga kirish yoki ro\'yxatdan o\'tish uchun telefon raqamingizni kiriting.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark),
          decoration: const InputDecoration(
            hintText: '+998 XX XXX XX XX',
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _onNextStep,
          child: Container(
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppColors.pinkGradient,
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Keyingi',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildNameStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ismingiz',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkPurple),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sizga murojaat qilishimiz uchun ismingizni kiriting.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textDark),
          decoration: const InputDecoration(
            hintText: 'Ismingizni kiriting',
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _step = 1;
                  });
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bgGray,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Orqaga',
                    style: TextStyle(color: AppColors.darkPurple, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _onSubmit,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.pinkGradient,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Kirish',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
