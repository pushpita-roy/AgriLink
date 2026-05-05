import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';

import 'utils/theme.dart';

import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/farmer/farmer_home_screen.dart';
import 'screens/buyer/buyer_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/common/orders_screen.dart';

void main() {
  runApp(const AgriLinkApp());
}

class AgriLinkApp extends StatelessWidget {
  const AgriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'AgriLink',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/farmer-home': (context) => const FarmerHomeScreen(),
          '/buyer-home': (context) => const BuyerHomeScreen(),
          '/admin-home': (context) => const AdminHomeScreen(),
          '/orders': (context) => const OrdersScreen(),
        },
      ),
    );
  }
}
