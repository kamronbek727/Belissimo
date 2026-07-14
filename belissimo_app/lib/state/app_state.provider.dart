import 'dart:math';
import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../services/persistence.dart';

class AppStateProvider extends ChangeNotifier {
  List<CartItem> _cart = [];
  List<String> _favorites = [];
  List<OrderData> _orders = [];
  OrderData? _latestOrder;
  
  bool _isLoggedIn = false;
  String _userName = 'Mehmon';
  String _userPhone = '';
  String _currentLocation = 'Navoiy shahri, Navoiy';

  AppStateProvider() {
    _loadState();
  }

  // --- Getters ---
  List<CartItem> get cart => _cart;
  List<String> get favorites => _favorites;
  List<OrderData> get orders => _orders;
  OrderData? get latestOrder => _latestOrder;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userPhone => _userPhone;
  String get currentLocation => _currentLocation;

  int get cartCount => _cart.fold(0, (sum, item) => sum + item.quantity);
  int get cartSubtotal => _cart.fold(0, (sum, item) => sum + item.total);
  int get deliveryFee {
    if (cartSubtotal == 0) return 0;
    return cartSubtotal > 100000 ? 0 : 10000;
  }
  int get cartTotal => cartSubtotal + deliveryFee;

  // --- Load state on start ---
  void _loadState() {
    _cart = PersistenceService.getCart();
    _favorites = PersistenceService.getFavorites();
    _orders = PersistenceService.getOrders();
    _latestOrder = PersistenceService.getLatestOrder();
    _isLoggedIn = PersistenceService.isLoggedIn();
    _userName = PersistenceService.getUserName();
    _userPhone = PersistenceService.getUserPhone();
    _currentLocation = PersistenceService.getLocation();
    notifyListeners();
  }

  // --- Cart Actions ---
  void addToCart(Product product, int price, int quantity, String size, List<String> extras) {
    final extrasKey = (extras..sort()).join(',');
    final index = _cart.indexWhere((item) =>
        item.id == product.id && item.size == size && item.extrasKey == extrasKey);

    if (index > -1) {
      _cart[index].quantity += quantity;
    } else {
      _cart.add(CartItem(
        id: product.id,
        name: product.name,
        price: price,
        image: product.imageAsset,
        size: size,
        extras: extras,
        extrasKey: extrasKey,
        quantity: quantity,
      ));
    }
    
    PersistenceService.saveCart(_cart);
    notifyListeners();
  }

  void changeCartQty(int index, int amount) {
    if (index >= 0 && index < _cart.length) {
      _cart[index].quantity += amount;
      if (_cart[index].quantity <= 0) {
        _cart.removeAt(index);
      }
      PersistenceService.saveCart(_cart);
      notifyListeners();
    }
  }

  void removeCartItem(int index) {
    if (index >= 0 && index < _cart.length) {
      _cart.removeAt(index);
      PersistenceService.saveCart(_cart);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    PersistenceService.saveCart(_cart);
    notifyListeners();
  }

  // --- Favorites Actions ---
  bool isFavorite(String id) => _favorites.contains(id);

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    PersistenceService.saveFavorites(_favorites);
    notifyListeners();
  }

  // --- Location Actions ---
  void setLocation(String location) {
    _currentLocation = location;
    PersistenceService.saveLocation(location);
    notifyListeners();
  }

  // --- Auth Actions ---
  void login(String name, String phone) {
    _isLoggedIn = true;
    _userName = name;
    _userPhone = phone;
    PersistenceService.saveLoggedIn(true);
    PersistenceService.saveUserName(name);
    PersistenceService.saveUserPhone(phone);
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = 'Mehmon';
    _userPhone = '';
    PersistenceService.clearProfile();
    notifyListeners();
  }

  void updateProfile(String name) {
    _userName = name;
    PersistenceService.saveUserName(name);
    notifyListeners();
  }

  // --- Orders Actions ---
  Future<bool> createOrder({
    required String deliveryType, // 'delivery' or 'pickup'
    required String paymentMethod, // 'cash' or 'card'
    String? address,
    double? latitude,
    double? longitude,
    String? apartmentOrOffice,
    String? landmark,
    String? courierComment,
    String? branch,
    required int subtotalValue,
    required int deliveryFeeValue,
    required String totalStr,
  }) async {
    if (_cart.isEmpty) return false;

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final orderId = '#BL${100000 + Random().nextInt(900000)}';
    final dateStr = DateTime.now().toLocal().toString().split(' ')[0].split('-').reversed.join('.'); // Format: DD.MM.YYYY

    final order = OrderData(
      id: orderId,
      customerId: _isLoggedIn ? _userPhone : 'guest',
      customerName: _userName,
      customerPhone: _userPhone,
      items: List<CartItem>.from(_cart),
      deliveryType: deliveryType,
      address: address,
      latitude: latitude,
      longitude: longitude,
      apartmentOrOffice: apartmentOrOffice,
      landmark: landmark,
      courierComment: courierComment,
      branch: branch,
      paymentMethod: paymentMethod,
      paymentStatus: paymentMethod == 'card' ? 'paid' : 'unpaid',
      subtotal: subtotalValue,
      deliveryFee: deliveryFeeValue,
      total: totalStr,
      status: 'new',
      date: dateStr,
    );

    _orders.insert(0, order);
    _latestOrder = order;

    await PersistenceService.saveOrders(_orders);
    await PersistenceService.saveLatestOrder(order);
    clearCart();

    return true;
  }
}
