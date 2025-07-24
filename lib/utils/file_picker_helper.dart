import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Platform-specific file picker implementation helper
class FilePickerHelper {
  /// Pick a file with the given allowed extensions
  static Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      // Use FilePickerResult directly to avoid platform-specific warnings
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
    } on PlatformException catch (e) {
      debugPrint('File picker error: ${e.message}');
    } catch (e) {
      debugPrint('File picker error: $e');
    }
    return null;
  }

  /// Pick multiple files with the given allowed extensions
  static Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files
            .where((file) => file.path != null)
            .map((file) => file.path!)
            .toList();
      }
    } on PlatformException catch (e) {
      debugPrint('File picker error: ${e.message}');
    } catch (e) {
      debugPrint('File picker error: $e');
    }
    return [];
  }

  /// Pick a directory
  static Future<String?> pickDirectory({
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Directory picker error: ${e.message}');
    } catch (e) {
      debugPrint('Directory picker error: $e');
    }
    return null;
  }

  /// Save file dialog
  static Future<String?> saveFile({
    required String fileName,
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      final result = await FilePicker.platform.saveFile(
        fileName: fileName,
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        dialogTitle: dialogTitle,
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('Save file error: ${e.message}');
    } catch (e) {
      debugPrint('Save file error: $e');
    }
    return null;
  }
}
