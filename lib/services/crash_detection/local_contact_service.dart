import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalContactService {
  static const String _key = 'local_emergency_contacts';

  static Future<void> saveContacts(List<String> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, contacts);
  }

  static Future<List<String>> getContacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
