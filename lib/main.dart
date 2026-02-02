import 'package:flutter/material.dart';
import 'package:kericho_delivery/presentation/router/app_router.dart';
import 'package:kericho_delivery/presentation/providers/app_provider.dart';
import 'package:kericho_delivery/presentation/providers/location_provider.dart';
import 'package:kericho_delivery/presentation/providers/merchant_provider.dart';
import 'package:kericho_delivery/presentation/providers/order_provider.dart';
import 'package:kericho_delivery/core/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive, Firebase, etc here
  // await initHive();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider.instance),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => MerchantProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Builder(
        builder: (context) {
          final appProvider = Provider.of<AppProvider>(context);
          
          return MaterialApp(
            title: 'Kericho Delivery',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appProvider.themeMode,
            locale: appProvider.locale,
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
            navigatorKey: AppRouter.navigatorKey,
          );
        },
      ),
    );
  }
}