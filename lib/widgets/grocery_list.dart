import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/widgets/category_section.dart'; // Import the new widget

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  double _budget = 100.0; // initial budget
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-db967-default-rtdb.firebaseio.com', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
            price: item.value['price'] ?? 0.0, // Load price if stored
            isChecked: item.value['isChecked'] ??
                false, // Load isChecked or default to false
          ),
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
        _updateBudget(); // Update the budget based on loaded items
      });
    } catch (error) {
      setState(() {
        _error = 'Something went wrong. Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https('flutter-prep-db967-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  void _updateBudget() {
    setState(() {
      _budget = 100.0;
      for (final item in _groceryItems) {
        if (item.isChecked) {
          _budget -= item.price;
        }
      }
    });
  }

  void _clearCheckedItems() {
    final checkedItems = _groceryItems.where((item) => item.isChecked).toList();

    for (final item in checkedItems) {
      _removeItem(item);
    }

    setState(() {
      _groceryItems.removeWhere((item) => item.isChecked);
      _updateBudget();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text(_error!));
    } else if (_groceryItems.isNotEmpty) {
      // Group items by category
      final Map<String, List<GroceryItem>> categorizedItems = {};
      for (final item in _groceryItems) {
        categorizedItems.putIfAbsent(item.category.title, () => []).add(item);
      }

      content = ListView(
        children: categorizedItems.entries.map((entry) {
          final categoryColor = categories.entries
              .firstWhere((cat) => cat.value.title == entry.key)
              .value
              .color;

          return CategorySection(
            categoryTitle: entry.key,
            items: entry.value,
            categoryColor: categoryColor,
            onCheckedChange:
                _updateBudget, // Make sure this is here if implemented
          );
        }).toList(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: content,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _clearCheckedItems,
              child: const Text('Clear Checked Items'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Budget: \$${_budget.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}
