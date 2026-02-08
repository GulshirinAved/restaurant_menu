import 'package:equatable/equatable.dart';
import 'package:restaurant_menu_app/features/menu/models/menu_item.dart';

class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, required this.quantity});

  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => menuItem.price * quantity;

  @override
  List<Object?> get props => [menuItem, quantity];
}
