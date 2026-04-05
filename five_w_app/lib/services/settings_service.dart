import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _backendIpKey = 'backend_ip';
  static const String _backendPortKey = 'backend_port';

  static Future<String> getBackendIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backendIpKey) ?? '';
  }

  static Future<String> getBackendPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_backendPortKey) ?? '8000';
  }

  static Future<String> getBackendUrl() async {
    final ip = await getBackendIp();
    final port = await getBackendPort();
    if (ip.isEmpty) return '';
    return 'http://$ip:$port';
  }

  static Future<void> setBackendIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendIpKey, ip.trim());
  }

  static Future<void> setBackendPort(String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendPortKey, port.trim());
  }

  static Future<bool> isConfigured() async {
    final ip = await getBackendIp();
    return ip.isNotEmpty;
  }
}
