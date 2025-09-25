import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';

/// A searchable dropdown widget for selecting categories
/// Shows category icons, colors, and names with search functionality
class CategoryPicker extends StatefulWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;
  final String? label;
  final bool isExpanded;

  const CategoryPicker({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onChanged,
    this.label,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  _CategoryPickerState createState() => _CategoryPickerState();
}

class _CategoryPickerState extends State<CategoryPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<Category> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
  }

  @override
  void didUpdateWidget(CategoryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _filterCategories(_searchController.text);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where((category) =>
                category.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _showCategoryPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Category'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search categories...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterCategories('');
                                },
                              )
                            : null,
                      ),
                      onChanged: _filterCategories,
                    ),
                    SizedBox(height: 16),
                    // Categories list
                    Expanded(
                      child: _filteredCategories.isEmpty
                          ? Center(
                              child: Text(
                                'No categories found',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = _filteredCategories[index];
                                final isSelected =
                                    widget.selectedCategory?.id == category.id;

                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        category.color.withValues(alpha: 0.2),
                                    child: Icon(
                                      category.icon,
                                      color: category.color,
                                    ),
                                  ),
                                  title: Text(
                                    category.title,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check,
                                          color: Theme.of(context).primaryColor,
                                        )
                                      : null,
                                  onTap: () {
                                    widget.onChanged(category);
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
        ],
        InkWell(
          onTap: _showCategoryPicker,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Selected category icon
                if (widget.selectedCategory != null) ...[
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        widget.selectedCategory!.color.withValues(alpha: 0.2),
                    child: Icon(
                      widget.selectedCategory!.icon,
                      color: widget.selectedCategory!.color,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  // Selected category name
                  Expanded(
                    child: Text(
                      widget.selectedCategory!.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ] else ...[
                  // Placeholder when no category is selected
                  Icon(
                    Icons.category,
                    color: Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Select a category',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
                // Dropdown arrow
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A simpler dropdown version of CategoryPicker for forms
class CategoryDropdownPicker extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;
  final String? label;
  final bool isExpanded;

  const CategoryDropdownPicker({
    Key? key,
    required this.categories,
    this.selectedCategory,
    required this.onChanged,
    this.label,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          SizedBox(height: 8),
        ],
        DropdownButtonFormField<Category>(
          value: selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
          isExpanded: isExpanded,
          hint: Text('Select a category'),
          items: categories.map((Category category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Row(
                children: [
                  Icon(
                    category.icon,
                    color: category.color,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(category.title),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
