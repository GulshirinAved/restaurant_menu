import 'package:equatable/equatable.dart';

class MenuItem extends Equatable {
  final String id;
  final String category;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool available;

  const MenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.available,
  });

  @override
  List<Object?> get props => [
    id,
    category,
    name,
    description,
    price,
    imageUrl,
    available,
  ];
}
