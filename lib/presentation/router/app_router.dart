import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/screens/splash_screen.dart';
import 'package:kericho_delivery/presentation/screens/onboarding_screen.dart';
import 'package:kericho_delivery/presentation/screens/auth/login_screen.dart';
import 'package:kericho_delivery/presentation/screens/auth/register_screen.dart';
import 'package:kericho_delivery/presentation/screens/home/home_screen.dart';
import 'package:kericho_delivery/presentation/screens/merchant/merchant_screen.dart';
import 'package:kericho_delivery/presentation/screens/cart/cart_screen.dart';
import 'package:kericho_delivery/presentation/screens/order/order_tracking_screen.dart';
import 'package:kericho_delivery/presentation/screens/profile/profile_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String merchant = '/merchant';
  static const String cart = '/cart';
  static const String orderTracking = '/order-tracking';
  static const String profile = '/profile';

  static String? orderHistory;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case merchant:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MerchantScreen(
            merchantId: args['merchantId'],
            merchantName: args['merchantName'],
          ),
        );
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case orderTracking:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderId: args['orderId']),
        );
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Future<dynamic> pushNamed(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<dynamic> pushReplacementNamed(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static void pop([dynamic result]) {
    navigatorKey.currentState!.pop(result);
  }

  static Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Map<String, dynamic>? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}