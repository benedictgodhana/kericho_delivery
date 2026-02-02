class AppConstants {
  static const String appName = 'Kericho Delivery';
  static const String appVersion = '1.0.0';
  
  // API Endpoints (replace with your actual backend URL)
  static const String baseUrl = 'http://your-backend-url.com/api';
  static const String devBaseUrl = 'http://10.0.2.2:3000/api'; // For emulator
  
  // Google Maps API Key
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';
  
  // Africa's Talking API
  static const String africasTalkingApiKey = 'YOUR_API_KEY';
  static const String africasTalkingUsername = 'sandbox';
  
  // Safaricom Daraja API
  static const String mpesaConsumerKey = 'YOUR_CONSUMER_KEY';
  static const String mpesaConsumerSecret = 'YOUR_CONSUMER_SECRET';
  static const String mpesaPassKey = 'YOUR_PASS_KEY';
  static const String mpesaBusinessShortCode = '174379';
  
  // Shared Preferences Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String locationKey = 'saved_location';
  static const String cartKey = 'cart_items';
  
  // App Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String merchantRoute = '/merchant';
  static const String cartRoute = '/cart';
  static const String orderTrackingRoute = '/order-tracking';
  static const String profileRoute = '/profile';
  
  // Animation Durations
  static const Duration animationDuration = Duration(milliseconds: 300);
}