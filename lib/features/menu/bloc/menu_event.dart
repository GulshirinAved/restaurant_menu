import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenu extends MenuEvent {}

class FilterMenuByCategory extends MenuEvent {
  final String category;
  const FilterMenuByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class AddMenuItem extends MenuEvent {
  final MenuItem item;
  const AddMenuItem(this.item);

  @override
  List<Object> get props => [item];
}
