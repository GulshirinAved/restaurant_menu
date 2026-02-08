import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';
import 'package:restaurant_menu_app/features/menu/services/excel_service.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final ExcelService _excelService;

  MenuBloc({ExcelService? excelService})
    : _excelService = excelService ?? ExcelService(),
      super(MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<FilterMenuByCategory>(_onFilterByCategory);
    on<AddMenuItem>(_onAddMenuItem);
  }

  // In-memory list to track current items
  final List<MenuItem> _currentItems = [];

  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(MenuLoading());
    try {
      // Step 1: Load from Excel
      final items = await _excelService.loadMenuFromExcel();

      _currentItems.clear();
      _currentItems.addAll(items);

      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to load menu: $e'));
    }
  }

  void _onFilterByCategory(
    FilterMenuByCategory event,
    Emitter<MenuState> emit,
  ) {
    if (state is MenuLoaded) {
      _emitLoaded(emit, _currentItems, selectedCategory: event.category);
    }
  }

  Future<void> _onAddMenuItem(
    AddMenuItem event,
    Emitter<MenuState> emit,
  ) async {
    try {
      // Step 1: Save to Excel file first
      await _excelService.addMenuItem(event.item);

      // Step 2: Update in-memory list
      _currentItems.add(event.item);

      // Step 3: Update UI state
      _emitLoaded(emit, List.from(_currentItems));
    } catch (e) {
      emit(MenuError('Failed to add item: $e'));
    }
  }

  void _emitLoaded(
    Emitter<MenuState> emit,
    List<MenuItem> items, {
    String? selectedCategory,
  }) {
    // 1. Filter available items
    final availableItems = items.where((i) => i.available).toList();

    // 2. Group by category
    final Map<String, List<MenuItem>> grouped = {};
    for (var item in availableItems) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }

    emit(
      MenuLoaded(
        allItems: availableItems,
        categorizedItems: grouped,
        selectedCategory: selectedCategory,
      ),
    );
  }
}
