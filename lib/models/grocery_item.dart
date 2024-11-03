import 'package:shopping_list/models/category.dart';

class GroceryItem {
  final String id;
  final String name;
  final int quantity;
  final Category category;
  final double price;
  bool isChecked; // New field to track the checked state

  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
    this.price = 0.0, // default val of zero
    this.isChecked = false, // Default to unchecked when an item is added
  });
}
