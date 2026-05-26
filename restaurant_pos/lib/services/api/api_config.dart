class ApiConfig {
  // Android emulator: 10.0.2.2, iOS simulator: localhost
  // Mặc định trỏ về Server Render để chạy thật
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://do-an-8s1b.onrender.com/api',
  );
}
