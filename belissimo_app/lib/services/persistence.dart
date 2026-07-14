import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

class PersistenceService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // --- Cart ---
  static List<CartItem> getCart() {
    final String? cartJson = _prefs?.getString('bellissimo_cart');
    if (cartJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(cartJson);
      return decoded.map((item) => CartItem.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCart(List<CartItem> cart) async {
    final List<Map<String, dynamic>> cartMaps = cart.map((item) => item.toJson()).toList();
    await _prefs?.setString('bellissimo_cart', json.encode(cartMaps));
  }

  // --- Favorites ---
  static List<String> getFavorites() {
    final String? favJson = _prefs?.getString('bellissimo_favorites');
    if (favJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(favJson);
      return List<String>.from(decoded);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFavorites(List<String> favorites) async {
    await _prefs?.setString('bellissimo_favorites', json.encode(favorites));
  }

  // --- Location ---
  static String getLocation() {
    return _prefs?.getString('bellissimo_location') ?? 'Navoiy shahri, Navoiy';
  }

  static Future<void> saveLocation(String location) async {
    await _prefs?.setString('bellissimo_location', location);
  }

  // --- Auth State ---
  static bool isLoggedIn() {
    return _prefs?.getBool('bellissimo_logged_in') ?? false;
  }

  static Future<void> saveLoggedIn(bool loggedIn) async {
    await _prefs?.setBool('bellissimo_logged_in', loggedIn);
  }

  static String getUserName() {
    return _prefs?.getString('bellissimo_user_name') ?? 'Mehmon';
  }

  static Future<void> saveUserName(String name) async {
    await _prefs?.setString('bellissimo_user_name', name);
  }

  static String getUserPhone() {
    return _prefs?.getString('bellissimo_user_phone') ?? '';
  }

  static Future<void> saveUserPhone(String phone) async {
    await _prefs?.setString('bellissimo_user_phone', phone);
  }

  // --- Orders ---
  static List<OrderData> getOrders() {
    final String? ordersJson = _prefs?.getString('bellissimo_orders');
    if (ordersJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(ordersJson);
      return decoded.map((item) => OrderData.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOrders(List<OrderData> orders) async {
    final List<Map<String, dynamic>> ordersMaps = orders.map((item) => item.toJson()).toList();
    await _prefs?.setString('bellissimo_orders', json.encode(ordersMaps));
  }

  static OrderData? getLatestOrder() {
    final String? orderJson = _prefs?.getString('bellissimo_latest_order');
    if (orderJson == null) return null;
    try {
      return OrderData.fromJson(json.decode(orderJson));
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveLatestOrder(OrderData order) async {
    await _prefs?.setString('bellissimo_latest_order', json.encode(order.toJson()));
  }

  // --- Clear Profile on Logout ---
  static Future<void> clearProfile() async {
    await saveLoggedIn(false);
    await saveUserName('Mehmon');
    await saveUserPhone('');
  }
}
