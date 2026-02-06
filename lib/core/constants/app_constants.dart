class AppConstants {
  static const String appName = 'Kericho Delivery';
  static const String appVersion = '1.0.0';

  // ── Change this to your real server URL in production ──
  static const String baseUrl = 'https://4a5c-41-81-160-213.ngrok-free.app/api';
  static const String apiBaseUrl = baseUrl;

  // Customer authentication endpoints
  static const String sendOtpEndpoint     = "$baseUrl/customer/send-otp";
  static const String verifyOtpEndpoint   = "$baseUrl/customer/verify-otp";
  static const String googleLoginEndpoint = "$baseUrl/customer/google/login";   // ← updated

  // Optional legacy (if you keep Socialite redirect flow)
  static const String googleCallbackEndpoint = "$baseUrl/customer/google/callback";

  static const String userProfileEndpoint = "$baseUrl/user/profile";
  static const String registerEndpoint    = "$baseUrl/customer/register";

  // Shared Preferences Keys
  static const String tokenKey       = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey        = 'user_data';
  static const String cartKey        = 'cart_items';

  // ... other constants (google maps key, etc.)
}