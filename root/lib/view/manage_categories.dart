import 'package:flutter/material.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/service/category_service.dart';
import 'package:p5_expense/view/widgets/category_badge.dart';

/// Screen for managing categories - add, edit, delete
/// Shows list of categories with options to modify them
class ManageCategoriesScreen extends StatefulWidget {
  final List<Category> categories;
  final VoidCallback onCategoriesChanged;
  final String userId;

  const ManageCategoriesScreen({
    Key? key,
    required this.categories,
    required this.onCategoriesChanged,
    required this.userId,
  }) : super(key: key);

  @override
  ManageCategoriesScreenState createState() => ManageCategoriesScreenState();
}

class ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  late List<Category> _categories;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  void didUpdateWidget(ManageCategoriesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      setState(() {
        _categories = List.from(widget.categories);
      });
    }
  }

  /// Refreshes the categories list from the service
  Future<void> _refreshCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final categories = await CategoryService.getAllCategories(widget.userId);
      setState(() {
        _categories = categories;
      });
      widget.onCategoriesChanged();
    } catch (e) {
      _showErrorSnackBar('Failed to refresh categories: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Shows the add/edit category dialog
  void _showCategoryDialog({Category? category}) {
    showDialog(
      context: context,
      builder: (context) => CategoryEditDialog(
        category: category,
        existingCategories: _categories,
        userId: widget.userId,
        onCategorySaved: () {
          _refreshCategories();
        },
      ),
    );
  }

  /// Shows confirmation dialog for category deletion
  void _showDeleteConfirmation(Category category) async {
    try {
      // Get transaction count for this category
      final transactionCount =
          await CategoryService.getTransactionCountForCategory(
              widget.userId, category.id);

      if (transactionCount > 0) {
        _showReassignmentDialog(category, transactionCount);
      } else {
        _showDeleteConfirmationDialog(category);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to check category usage: $e');
    }
  }

  /// Shows dialog for confirming deletion when no transactions use the category
  void _showDeleteConfirmationDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCategory(category.id, null);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog for reassignment when transactions use the category
  void _showReassignmentDialog(Category category, int transactionCount) {
    showDialog(
      context: context,
      builder: (context) => ReassignmentDialog(
        category: category,
        transactionCount: transactionCount,
        availableCategories:
            _categories.where((c) => c.id != category.id).toList(),
        onReassignmentConfirmed: (replacementCategoryId) async {
          Navigator.of(context).pop();
          await _deleteCategory(category.id, replacementCategoryId);
        },
      ),
    );
  }

  /// Deletes a category with optional reassignment
  Future<void> _deleteCategory(
      String categoryId, String? replacementCategoryId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (replacementCategoryId != null) {
        await CategoryService.deleteCategory(
          userId: widget.userId,
          categoryId: categoryId,
          replacementCategoryId: replacementCategoryId,
        );
      } else {
        // This shouldn't happen in normal flow, but handle it gracefully
        await CategoryService.deleteCategory(
          userId: widget.userId,
          categoryId: categoryId,
          replacementCategoryId: 'other', // Default to 'other'
        );
      }

      _showSuccessSnackBar('Category deleted successfully');
      await _refreshCategories();
    } catch (e) {
      _showErrorSnackBar('Failed to delete category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshCategories,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshCategories,
              child: _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.category,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No categories found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap the + button to add your first category',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
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
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: CategoryBadge(
                              category: category,
                              showIcon: false,
                              fontSize: 12,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () =>
                                      _showCategoryDialog(category: category),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () =>
                                      _showDeleteConfirmation(category),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        tooltip: 'Add Category',
        child: Icon(Icons.add),
      ),
    );
  }
}

/// Dialog for adding/editing categories
class CategoryEditDialog extends StatefulWidget {
  final Category? category;
  final List<Category> existingCategories;
  final String userId;
  final VoidCallback onCategorySaved;

  const CategoryEditDialog({
    Key? key,
    this.category,
    required this.existingCategories,
    required this.userId,
    required this.onCategorySaved,
  }) : super(key: key);

  @override
  CategoryEditDialogState createState() => CategoryEditDialogState();
}

class CategoryEditDialogState extends State<CategoryEditDialog> {
  late TextEditingController _titleController;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isLoading = false;

  // Available colors for selection
  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  // Available icons for selection
  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_car,
    Icons.receipt,
    Icons.movie,
    Icons.shopping_bag,
    Icons.local_hospital,
    Icons.category,
    Icons.home,
    Icons.work,
    Icons.school,
    Icons.fitness_center,
    Icons.flight,
    Icons.hotel,
    Icons.phone,
    Icons.computer,
    Icons.book,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.pets,
    Icons.child_care,
  ];

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.category?.title ?? '');
    _selectedColor = widget.category?.color ?? Colors.blue;
    _selectedIcon = widget.category?.icon ?? Icons.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_titleController.text.trim().isEmpty) {
      _showErrorSnackBar('Category name cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (widget.category != null) {
        // Update existing category
        await CategoryService.updateCategory(
          userId: widget.userId,
          categoryId: widget.category!.id,
          title: _titleController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        );
      } else {
        // Create new category
        await CategoryService.createCategory(
          userId: widget.userId,
          title: _titleController.text.trim(),
          color: _selectedColor,
          icon: _selectedIcon,
        );
      }

      widget.onCategorySaved();
      Navigator.of(context).pop();
      _showSuccessSnackBar(
        widget.category != null ? 'Category updated' : 'Category created',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to save category: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category != null ? 'Edit Category' : 'Add Category'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category name input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 16),

            // Color selection
            Text(
              'Color',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableColors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : Border.all(color: Colors.grey, width: 1),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Icon selection
            Text(
              'Icon',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _availableIcons.map((icon) {
                final isSelected = icon == _selectedIcon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? _selectedColor : Colors.grey.shade200,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _selectedColor : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 20,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveCategory,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.category != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

/// Dialog for confirming category deletion with reassignment
class ReassignmentDialog extends StatefulWidget {
  final Category category;
  final int transactionCount;
  final List<Category> availableCategories;
  final Function(String) onReassignmentConfirmed;

  const ReassignmentDialog({
    Key? key,
    required this.category,
    required this.transactionCount,
    required this.availableCategories,
    required this.onReassignmentConfirmed,
  }) : super(key: key);

  @override
  ReassignmentDialogState createState() => ReassignmentDialogState();
}

class ReassignmentDialogState extends State<ReassignmentDialog> {
  Category? _selectedReplacementCategory;

  @override
  void initState() {
    super.initState();
    // Default to 'other' category if available, otherwise use the first available category
    try {
      _selectedReplacementCategory =
          widget.availableCategories.firstWhere((cat) => cat.id == 'other');
    } catch (e) {
      // If 'other' category doesn't exist, use the first available category
      if (widget.availableCategories.isNotEmpty) {
        _selectedReplacementCategory = widget.availableCategories.first;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Category'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The category "${widget.category.title}" is used by ${widget.transactionCount} transaction(s).',
          ),
          SizedBox(height: 16),
          Text(
            'Choose a replacement category for these transactions:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<Category>(
            value: _selectedReplacementCategory,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
            items: widget.availableCategories.map((Category category) {
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
                    Text(category.title),
                  ],
                ),
              );
            }).toList(),
            onChanged: (Category? newValue) {
              setState(() {
                _selectedReplacementCategory = newValue;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedReplacementCategory != null
              ? () => widget
                  .onReassignmentConfirmed(_selectedReplacementCategory!.id)
              : null,
          child: Text('Delete & Reassign'),
        ),
      ],
    );
  }
}
