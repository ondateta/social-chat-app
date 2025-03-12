import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  
  AuthService._internal();

  static const String _storageKey = 'user_auth';
  static const String _usersKey = 'registered_users';
  static const String _updatesKey = 'user_updates';

  Future<void> signIn(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Get registered users
    final users = await _getRegisteredUsers();
    
    // Find user with matching email
    final user = users.firstWhere(
      (user) => user['email'] == email,
      orElse: () => {},
    );
    
    if (user.isEmpty) {
      throw Exception('No account found with this email');
    }
    
    if (user['password'] != password) {
      throw Exception('Invalid password');
    }
    
    // Store user session
    final userData = {
      'id': user['id'],
      'email': user['email'],
      'username': user['username'],
      'isLoggedIn': true,
    };
    
    await _saveUserData(userData);
  }

  Future<void> createAccount(String email, String password, String username) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Get registered users
    final users = await _getRegisteredUsers();
    
    // Check if email already exists
    final emailExists = users.any((user) => user['email'] == email);
    if (emailExists) {
      throw Exception('Email already in use');
    }
    
    // Check if username already exists
    final usernameExists = users.any((user) => user['username'] == username);
    if (usernameExists) {
      throw Exception('Username already taken');
    }
    
    // Create new user
    final newUser = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email,
      'password': password,
      'username': username,
    };
    
    // Add to registered users
    users.add(newUser);
    await _saveRegisteredUsers(users);
    
    // Auto login
    final userData = {
      'id': newUser['id'],
      'email': newUser['email'],
      'username': newUser['username'],
      'isLoggedIn': true,
    };
    
    await _saveUserData(userData);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<bool> isLoggedIn() async {
    final userData = await getUserData();
    return userData != null && userData['isLoggedIn'] == true;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_storageKey);
    
    if (userDataString == null) {
      return null;
    }
    
    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding user data: $e');
      return null;
    }
  }

  Future<void> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Get registered users
    final users = await _getRegisteredUsers();
    
    // Check if email exists
    final emailExists = users.any((user) => user['email'] == email);
    if (!emailExists) {
      throw Exception('No account found with this email');
    }
    
    // In a real app, send email with reset instructions
    // For this demo, we'll just pretend we did
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(userData));
  }

  Future<List<Map<String, dynamic>>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersString = prefs.getString(_usersKey);
    
    if (usersString == null) {
      return [];
    }
    
    try {
      final List<dynamic> decodedList = jsonDecode(usersString);
      return decodedList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error decoding users: $e');
      return [];
    }
  }

  Future<void> _saveRegisteredUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }
  
  // Update-related methods
  
  Future<List<Map<String, dynamic>>> getUserUpdates() async {
    final userData = await getUserData();
    if (userData == null) {
      return [];
    }
    
    final prefs = await SharedPreferences.getInstance();
    final updatesString = prefs.getString('${_updatesKey}_${userData['id']}');
    
    if (updatesString == null) {
      return [];
    }
    
    try {
      final List<dynamic> decodedList = jsonDecode(updatesString);
      return List<Map<String, dynamic>>.from(decodedList);
    } catch (e) {
      debugPrint('Error decoding updates: $e');
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getAllUpdates() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> allUpdates = [];
    
    // Get all keys
    final keys = prefs.getKeys();
    
    // Filter update keys
    final updateKeys = keys.where((key) => key.startsWith(_updatesKey)).toList();
    
    // Combine all updates
    for (final key in updateKeys) {
      final updatesString = prefs.getString(key);
      if (updatesString != null) {
        try {
          final List<dynamic> updates = jsonDecode(updatesString);
          allUpdates.addAll(List<Map<String, dynamic>>.from(updates));
        } catch (e) {
          debugPrint('Error decoding updates for key $key: $e');
        }
      }
    }
    
    // Sort by timestamp (newest first)
    allUpdates.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
    
    return allUpdates;
  }
  
  Future<void> createUpdate(String content) async {
    final userData = await getUserData();
    if (userData == null) {
      throw Exception('User not logged in');
    }
    
    final userId = userData['id'];
    final username = userData['username'];
    
    final newUpdate = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'username': username,
      'content': content,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'likes': 0,
      'comments': 0,
    };
    
    final updates = await getUserUpdates();
    updates.add(newUpdate);
    
    await _saveUserUpdates(userId, updates);
  }
  
  Future<void> updateUpdate(String updateId, String content) async {
    final userData = await getUserData();
    if (userData == null) {
      throw Exception('User not logged in');
    }
    
    final userId = userData['id'];
    final updates = await getUserUpdates();
    
    final index = updates.indexWhere((update) => update['id'] == updateId);
    if (index == -1) {
      throw Exception('Update not found');
    }
    
    updates[index]['content'] = content;
    updates[index]['edited'] = true;
    
    await _saveUserUpdates(userId, updates);
  }
  
  Future<void> deleteUpdate(String updateId) async {
    final userData = await getUserData();
    if (userData == null) {
      throw Exception('User not logged in');
    }
    
    final userId = userData['id'];
    final updates = await getUserUpdates();
    
    final filteredUpdates = updates.where((update) => update['id'] != updateId).toList();
    
    await _saveUserUpdates(userId, filteredUpdates);
  }
  
  Future<void> _saveUserUpdates(String userId, List<Map<String, dynamic>> updates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_updatesKey}_$userId', jsonEncode(updates));
  }
  
  Future<int> getUserUpdatesCount() async {
    final updates = await getUserUpdates();
    return updates.length;
  }
}