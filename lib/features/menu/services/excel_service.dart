import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

/// Service for handling Excel file operations
///
/// Logical Flow:
/// 1. Check/Request storage permissions (Android only)
/// 2. Get the Excel file path (Documents/menu.xlsx)
/// 3. If file doesn't exist, create it with headers
/// 4. If file exists, load it
/// 5. Add new menu item as a row
/// 6. Save the file back
class ExcelService {
  static const String _fileName = 'menu.xlsx';
  static const String _sheetName = 'Menu';

  /// Get the path where Excel file will be stored
  /// For Android: /storage/emulated/0/Documents/menu.xlsx
  /// For other platforms: app documents directory
  Future<String> getExcelFilePath() async {
    if (Platform.isAndroid) {
      // Use public Documents folder on Android
      return '/storage/emulated/0/Documents/$_fileName';
    } else {
      final directory = await getApplicationDocumentsDirectory();
      return '${directory.path}/$_fileName';
    }
  }

  /// Request storage permission (Android only)
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;

    // For Android 11+, we need MANAGE_EXTERNAL_STORAGE
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      status = await Permission.manageExternalStorage.request();
    }

    // Fallback to regular storage permission
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  /// Create a new Excel file with headers
  Future<void> _createExcelFile(String path) async {
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row
    sheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('Name'),
      TextCellValue('Description'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    // Save the file
    final bytes = excel.save();
    if (bytes != null) {
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }

  /// Add a menu item to the Excel file
  ///
  /// Logic:
  /// 1. Request permission
  /// 2. Get file path
  /// 3. Check if file exists, create if not
  /// 4. Load Excel file
  /// 5. Append new row with menu item data
  /// 6. Save file
  Future<void> addMenuItem(MenuItem item) async {
    // Step 1: Request permission
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Storage permission denied');
    }

    // Step 2: Get file path
    final path = await getExcelFilePath();
    final file = File(path);

    // Step 3: Create file if it doesn't exist
    if (!await file.exists()) {
      await _createExcelFile(path);
    }

    // Step 4: Load Excel file
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the Menu sheet (or first sheet if Menu doesn't exist)
    Sheet? sheet = excel.tables[_sheetName];
    sheet ??= excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      throw Exception('No sheet found in Excel file');
    }

    // Step 5: Append new row
    sheet.appendRow([
      TextCellValue(item.category),
      TextCellValue(item.name),
      TextCellValue(item.description),
      TextCellValue(item.price.toString()),
      TextCellValue(item.imageUrl),
      TextCellValue(item.available ? 'TRUE' : 'FALSE'),
    ]);

    // Step 6: Save file
    final newBytes = excel.save();
    if (newBytes != null) {
      await file.writeAsBytes(newBytes, flush: true);
    }
  }

  /// Save all menu items to Excel (overwrites existing file)
  Future<void> saveAllMenuItems(List<MenuItem> items) async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Storage permission denied');
    }

    final path = await getExcelFilePath();
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row
    sheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('Name'),
      TextCellValue('Description'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    // Add all items
    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.category),
        TextCellValue(item.name),
        TextCellValue(item.description),
        TextCellValue(item.price.toString()),
        TextCellValue(item.imageUrl),
        TextCellValue(item.available ? 'TRUE' : 'FALSE'),
      ]);
    }

    // Save file
    final bytes = excel.save();
    if (bytes != null) {
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
    }
  }

  /// Load all menu items from the Excel file
  ///
  /// Logic:
  /// 1. Request permission
  /// 2. Get file path
  /// 3. If file doesn't exist, return empty list
  /// 4. Load Excel file
  /// 5. Parse each row (skipping header) into MenuItem
  Future<List<MenuItem>> loadMenuFromExcel() async {
    // Step 1: Request permission
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Storage permission denied');
    }

    // Step 2: Get file path
    final path = await getExcelFilePath();
    final file = File(path);

    // Step 3: Check if file exists
    if (!await file.exists()) {
      return [];
    }

    // Step 4: Load Excel file
    // The loading logic is now wrapped in the try-catch block below to handle corruption.

    try {
      // Step 4: Load Excel file
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables[_sheetName];
      sheet ??= excel.tables[excel.tables.keys.first];

      if (sheet == null) return [];

      final List<MenuItem> items = [];

      // Step 5: Parse rows (skip header row at index 0)
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty) continue;

        try {
          // Expected columns: Category, Name, Description, Price, Image URL, Available
          final category = row[0]?.value.toString() ?? '';
          final name = row[1]?.value.toString() ?? '';
          final description = row[2]?.value.toString() ?? '';
          final priceString = row[3]?.value.toString() ?? '0.0';
          final imageUrl = row[4]?.value.toString() ?? '';
          final availableString =
              row[5]?.value.toString().toUpperCase() ?? 'TRUE';

          if (name.isEmpty) continue;

          items.add(
            MenuItem(
              id: i.toString(),
              category: category,
              name: name,
              description: description,
              price: double.tryParse(priceString) ?? 0.0,
              imageUrl: imageUrl,
              available: availableString == 'TRUE',
            ),
          );
        } catch (e) {
          // Silent error for safe loading of individual rows
        }
      }

      return items;
    } catch (e) {
      // Catch corruption errors (like numFmtId)
      print('Error loading Excel file: $e. Recreating file...');
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (deleteError) {
        print('Failed to delete corrupted file: $deleteError');
      }
      return []; // Return empty so default items are used
    }
  }
}
