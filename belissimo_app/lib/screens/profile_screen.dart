import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme.dart';
import '../state/app_state.provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isPersonalExpanded = false;
  final TextEditingController _nameEditController = TextEditingController();

  @override
  void dispose() {
    _nameEditController.dispose();
    super.dispose();
  }

  void _onSaveProfile(AppStateProvider appState) {
    final newName = _nameEditController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iltimos, ismingizni kiriting! 👤'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    appState.updateProfile(newName);
    setState(() {
      _isPersonalExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ma\'lumotlar saqlandi! 💾'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    if (!appState.isLoggedIn) {
      return const LoginScreen();
    }

    // Initialize controller value once when panel is opened
    if (_nameEditController.text != appState.userName && !_isPersonalExpanded) {
      _nameEditController.text = appState.userName;
    }

    return Scaffold(
      backgroundColor: AppColors.bgGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profil'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Info Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppColors.borderColor),
              ),
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // SVG Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.bgGray,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      'assets/images/avatar.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkPurple,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appState.userPhone,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Info Accordion Panel
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(color: AppColors.borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPersonalExpanded = !_isPersonalExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.person_outline_rounded, color: AppColors.darkPurple),
                              SizedBox(width: 12),
                              Text(
                                'Shaxsiy ma\'lumotlar',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkPurple,
                                ),
                              ),
                            ],
                          ),
                          AnimatedRotation(
                            turns: _isPersonalExpanded ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(Icons.keyboard_arrow_right_rounded, color: AppColors.textMuted),
                          )
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Divider(color: AppColors.borderColor),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameEditController,
                            decoration: const InputDecoration(
                              labelText: 'Ism',
                              hintText: 'Ismingizni kiriting',
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _onSaveProfile(appState),
                            child: Container(
                              height: 48,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: AppColors.pinkGradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Saqlash',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    crossFadeState: _isPersonalExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 200),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button
            GestureDetector(
              onTap: () {
                appState.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tizimdan chiqildi! 🔒'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: AppColors.borderColor),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Tizimdan chiqish',
                  style: TextStyle(
                    color: AppColors.pinkAccent,
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
