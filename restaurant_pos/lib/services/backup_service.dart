import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class BackupService {
  Future<String?> backupDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'restaurant.db');
      final file = File(path);

      if (await file.exists()) {
        final tempDir = await getTemporaryDirectory();
        final backupPath = join(tempDir.path, 'restaurant_backup.db');
        await file.copy(backupPath);
        return backupPath;
      }
    } catch (e) {
      debugPrint('Backup error: $e');
    }
    return null;
  }

  Future<void> shareBackup() async {
    final path = await backupDatabase();
    if (path != null) {
      await Share.shareXFiles([XFile(path)], text: 'Du lieu du phong POS');
    }
  }

  Future<bool> restoreDatabase(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) return false;

      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'restaurant.db');

      await backupFile.copy(path);
      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  Future<void> createBackup() async {
    await shareBackup();
  }
}
