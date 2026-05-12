import 'package:hive/hive.dart';

class LocalContactService {
  static const String _key = 'emergency_contacts';

  static Future<void> saveContacts(List<String> contacts) async {
    final userBox = Hive.box('user_box');
    await userBox.put(_key, contacts);
  }

  static Future<List<String>> getContacts() async {
    final userBox = Hive.box('user_box');
    final List<dynamic>? contacts = userBox.get(_key);
    return contacts?.map((e) => e.toString()).toList() ?? [];
  }
}
