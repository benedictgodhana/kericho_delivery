import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/screens/splash_screen.dart';
import 'package:kericho_delivery/presentation/screens/onboarding_screen.dart';
import 'package:kericho_delivery/presentation/screens/auth/login_screen.dart';
import 'package:kericho_delivery/presentation/screens/auth/register_screen.dart';
import 'package:kericho_delivery/presentation/screens/auth/auth_prompt_screen.dart';
import 'package:kericho_delivery/presentation/screens/home/home_screen.dart';
import 'package:kericho_delivery/presentation/screens/menu/menu_screen.dart';
import 'package:kericho_delivery/presentation/screens/merchant/merchant_screen.dart';
import 'package:kericho_delivery/presentation/screens/cart/cart_screen.dart';
import 'package:kericho_delivery/presentation/screens/order/order_history_screen.dart';
import 'package:kericho_delivery/presentation/screens/order/order_tracking_screen.dart';
import 'package:kericho_delivery/presentation/screens/profile/profile_screen.dart';
import 'package:kericho_delivery/presentation/screens/profile/edit_profile_screen.dart';
import 'package:kericho_delivery/presentation/screens/profile/addresses_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/favorites_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/payment_methods_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/notifications_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/promotions_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/help_support_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/settings_screen.dart';
import 'package:kericho_delivery/presentation/screens/account/privacy_security_screen.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String authPrompt = '/authPrompt';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String merchant = '/merchant';
  static const String cart = '/cart';
  static const String orderTracking = '/order-tracking';
  static const String profile = '/profile';
  static const String orderHistory = '/order-history';
  static const String editProfile = '/editProfile';
  static const String addresses = '/addresses';
  static const String favorites = '/favorites';
  static const String paymentMethods = '/paymentMethods';
  static const String notifications = '/notifications';
  static const String promotions = '/promotions';
  static const String help = '/help';
  static const String settingsRoute = '/settings';
  static const String privacy = '/privacy';

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
      case authPrompt:
        return MaterialPageRoute(builder: (_) => const AuthPromptScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case menu:
        return MaterialPageRoute(builder: (_) => const MenuScreen());
      case merchant:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MerchantScreen(
            merchantId: args['merchantId'],
            merchantName: args['merchantName'],
            merchantImageUrl: args['merchantImageUrl'],
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
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case editProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(user: args?['user']),
        );
      case addresses:
        return MaterialPageRoute(builder: (_) => const AddressesScreen());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case paymentMethods:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case promotions:
        return MaterialPageRoute(builder: (_) => const PromotionsScreen());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacySecurityScreen());
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
