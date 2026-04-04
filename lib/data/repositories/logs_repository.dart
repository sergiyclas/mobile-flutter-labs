import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workspace_guard/data/api/api_client.dart';

class LogModel {
  final String id;
  final int distance;
  final bool motion;
  final String timestamp;

  LogModel({
    required this.id,
    required this.distance,
    required this.motion,
    required this.timestamp,
  });

  factory LogModel.fromJson(String id, Map<String, dynamic> json) {
    return LogModel(
      id: id,
      distance: (json['distance'] ?? 0) as int,
      motion: (json['motion'] ?? false) as bool,
      timestamp: json['timestamp']?.toString() ?? 'Невідомий час',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'distance': distance,
    'motion': motion,
    'timestamp': timestamp,
  };
}

class LogsRepository {
  final ApiClient _apiClient;

  LogsRepository(this._apiClient);

  // Додано параметр userId
  Future<List<LogModel>> getLogs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_logs_$userId'; // Кеш тепер унікальний для юзера

    try {
      // Звертаємося до персональної папки юзера
      final response = await _apiClient.dbClient.get<dynamic>(
        'users/$userId/logs.json',
      );
      
      if (response.data != null && response.data != '') {
        List<LogModel> freshLogs = [];
        
        // Обробка даних (навіть якщо Firebase поверне List замість Map)
        if (response.data is Map) {
          final dataMap = response.data as Map<dynamic, dynamic>;
          freshLogs = dataMap.entries.map((entry) {
            return LogModel.fromJson(
              entry.key.toString(), 
              Map<String, dynamic>.from(entry.value as Map),
            );
          }).toList();
        } else if (response.data is List) {
          final dataList = response.data as List<dynamic>;
          for (int i = 0; i < dataList.length; i++) {
            if (dataList[i] != null) {
              freshLogs.add(LogModel.fromJson(
                i.toString(), 
                Map<String, dynamic>.from(dataList[i] as Map),
              ),);
            }
          }
        }

        final cacheData = freshLogs.map((l) => l.toJson()).toList();
        await prefs.setString(cacheKey, jsonEncode(cacheData));
        
        return freshLogs.reversed.toList(); 
      }
      return [];
      
    } catch (e) {
      debugPrint('Error during log retrieval: $e');
      
      final cachedString = prefs.getString(cacheKey);
      
      if (cachedString != null) {
        final decodedList = jsonDecode(cachedString) as List<dynamic>;
        return decodedList.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          final id = map['id']?.toString() ?? 'offline';
          return LogModel.fromJson(id, map);
        }).toList().reversed.toList();
      }
      
      return []; 
    }
  }

  // Збереження також іде в персональну папку
  Future<void> addLog(String userId, LogModel log) async {
    try {
      await _apiClient.dbClient.post<dynamic>(
        'users/$userId/logs.json',
        data: log.toJson(),
      );
      debugPrint('Log successfully saved for $userId');
    } catch (e) {
      debugPrint('Error saving log: $e');
    }
  }
}
