import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

/// Service for handling Excel file operations
///
/// Uses app-specific directory which doesn't require special storage permissions.
///
/// Logical Flow:
/// 1. Get the Excel file path (app documents directory)
/// 2. If file doesn't exist, create it with headers
/// 3. If file exists, load it
/// 4. Add new menu item as a row
/// 5. Save the file back
class ExcelService {
  static const String _fileName = 'menu.xlsx';
  static const String _sheetName = 'Menu';

  /// Get the path where Excel file will be stored
  /// Uses app-specific directory (no special permissions needed)
  Future<String> getExcelFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_fileName';
  }

  /// Create a new Excel file with headers
  Future<void> _createExcelFile(String path) async {
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row with multilang support
    sheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('NameEn'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('DescriptionEn'),
      TextCellValue('DescriptionRu'),
      TextCellValue('DescriptionTk'),
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
  /// 1. Get file path
  /// 2. Check if file exists, create if not
  /// 3. Load Excel file
  /// 4. Append new row with menu item data
  /// 5. Save file
  Future<void> addMenuItem(MenuItem item) async {
    // Step 1: Get file path
    final path = await getExcelFilePath();
    final file = File(path);

    // Step 2: Create file if it doesn't exist
    if (!await file.exists()) {
      await _createExcelFile(path);
    }

    // Step 3: Load Excel file
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);

    // Get the Menu sheet (or first sheet if Menu doesn't exist)
    Sheet? sheet = excel.tables[_sheetName];
    sheet ??= excel.tables[excel.tables.keys.first];

    if (sheet == null) {
      throw Exception('No sheet found in Excel file');
    }

    // Step 4: Append new row with multilang support
    sheet.appendRow([
      TextCellValue(item.category),
      TextCellValue(item.nameEn),
      TextCellValue(item.nameRu),
      TextCellValue(item.nameTk),
      TextCellValue(item.descriptionEn),
      TextCellValue(item.descriptionRu),
      TextCellValue(item.descriptionTk),
      TextCellValue(item.price.toString()),
      TextCellValue(item.imageUrl),
      TextCellValue(item.available ? 'TRUE' : 'FALSE'),
    ]);

    // Step 5: Save file
    final newBytes = excel.save();
    if (newBytes != null) {
      await file.writeAsBytes(newBytes, flush: true);
    }
  }

  /// Save all menu items to Excel (overwrites existing file)
  Future<void> saveAllMenuItems(List<MenuItem> items) async {
    final path = await getExcelFilePath();
    final excel = Excel.createExcel();
    final sheet = excel[_sheetName];

    // Add header row with multilang support
    sheet.appendRow([
      TextCellValue('Category'),
      TextCellValue('NameEn'),
      TextCellValue('NameRu'),
      TextCellValue('NameTk'),
      TextCellValue('DescriptionEn'),
      TextCellValue('DescriptionRu'),
      TextCellValue('DescriptionTk'),
      TextCellValue('Price'),
      TextCellValue('Image URL'),
      TextCellValue('Available'),
    ]);

    // Add all items
    for (final item in items) {
      sheet.appendRow([
        TextCellValue(item.category),
        TextCellValue(item.nameEn),
        TextCellValue(item.nameRu),
        TextCellValue(item.nameTk),
        TextCellValue(item.descriptionEn),
        TextCellValue(item.descriptionRu),
        TextCellValue(item.descriptionTk),
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
  /// 1. Get file path
  /// 2. If file doesn't exist, return empty list
  /// 3. Load Excel file
  /// 4. Parse each row (skipping header) into MenuItem
  Future<List<MenuItem>> loadMenuFromExcel() async {
    // Step 1: Get file path
    final path = await getExcelFilePath();
    final file = File(path);

    // Step 2: Check if file exists
    if (!await file.exists()) {
      return [];
    }

    // Step 3: Load Excel file
    // The loading logic is now wrapped in the try-catch block below to handle corruption.

    try {
      // Step 3: Load Excel file
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      Sheet? sheet = excel.tables[_sheetName];
      sheet ??= excel.tables[excel.tables.keys.first];

      if (sheet == null) return [];

      final List<MenuItem> items = [];

      // Step 4: Parse rows (skip header row at index 0)
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty) continue;

        try {
          // Expected columns: Category, NameEn, NameRu, NameTk, DescEn, DescRu, DescTk, Price, ImageURL, Available
          final category = row[0]?.value.toString() ?? '';
          final nameEn = row[1]?.value.toString() ?? '';
          final nameRu = row[2]?.value.toString() ?? '';
          final nameTk = row[3]?.value.toString() ?? '';
          final descriptionEn = row[4]?.value.toString() ?? '';
          final descriptionRu = row[5]?.value.toString() ?? '';
          final descriptionTk = row[6]?.value.toString() ?? '';
          final priceString = row[7]?.value.toString() ?? '0.0';
          final imageUrl = row[8]?.value.toString() ?? '';
          final availableString = row[9]?.value.toString().toUpperCase() ?? 'TRUE';

          if (nameEn.isEmpty) continue;

          items.add(
            MenuItem(
              id: i.toString(),
              category: category,
              nameEn: nameEn,
              nameRu: nameRu,
              nameTk: nameTk,
              descriptionEn: descriptionEn,
              descriptionRu: descriptionRu,
              descriptionTk: descriptionTk,
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
