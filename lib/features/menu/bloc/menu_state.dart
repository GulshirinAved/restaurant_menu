import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItem> allItems;
  final Map<String, List<MenuItem>> categorizedItems;
  final String? selectedCategory;

  const MenuLoaded({
    required this.allItems,
    required this.categorizedItems,
    this.selectedCategory,
  });

  @override
  List<Object> get props => [
    allItems,
    categorizedItems,
    selectedCategory ?? '',
  ];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}
