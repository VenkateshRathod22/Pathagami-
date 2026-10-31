import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_preferences_model.dart';

class NotificationPreferencesService {
  static final NotificationPreferencesService instance = NotificationPreferencesService._();
  NotificationPreferencesService._();

  static const String _storageKey = 'spingo_notification_preferences';

  // Future API Endpoint (User can plug in anytime)
  static const String apiEndpoint = 'https://spingoride.com/api/v1/user/notifications/preferences';

  /// Load preferences from local storage, defaults to all enabled
  Future<NotificationPreferencesModel> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(raw);
        return NotificationPreferencesModel.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
    }
    return const NotificationPreferencesModel();
  }

  /// Save preferences locally and sync to API
  Future<bool> savePreferences(NotificationPreferencesModel model, {String? authToken}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(model.toJson()));

      // Future API sync hook:
      // if (authToken != null) {
      //   await http.post(
      //     Uri.parse(apiEndpoint),
      //     headers: {
      //       'Content-Type': 'application/json',
      //       'Authorization': 'Bearer $authToken',
      //     },
      //     body: jsonEncode(model.toJson()),
      //   );
      // }
      return true;
    } catch (e) {
      debugPrint('Error saving notification preferences: $e');
      return false;
    }
  }
}
