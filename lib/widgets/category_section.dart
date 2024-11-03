import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';

class CategorySection extends StatefulWidget {
  final String categoryTitle;
  final List<GroceryItem> items;
  final Color categoryColor;

  const CategorySection({
    required this.categoryTitle,
    required this.items,
    required this.categoryColor,
    Key? key,
  }) : super(key: key);

  @override
  _CategorySectionState createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            widget.categoryTitle,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: widget.categoryColor,
                ),
          ),
        ),
        ...widget.items.map(
          (item) => ListTile(
            leading: Checkbox(
              value: item.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  item.isChecked = value ?? false;
                });
              },
            ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Text(
              'Qty: ${item.quantity}',
              style: TextStyle(
                color: Colors.grey[600],
                decoration: item.isChecked
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
