import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/service/budget_service.dart';
import 'package:p5_expense/model/budget.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/widgets/category_picker.dart';

/// Screen for creating a new budget
/// Follows the same pattern as NewSavingsGoalScreen and NewTransaction
class NewBudgetScreen extends StatefulWidget {
  final List<Category> categories;

  const NewBudgetScreen({super.key, required this.categories});

  @override
  State<NewBudgetScreen> createState() => _NewBudgetScreenState();
}

class _NewBudgetScreenState extends State<NewBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetType _selectedType = BudgetType.OVERALL;
  BudgetPeriod _selectedPeriod = BudgetPeriod.MONTHLY;
  Category? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _updateTypeAndDateRange() {
    final now = DateTime.now();
    setState(() {
      switch (_selectedPeriod) {
        case BudgetPeriod.WEEKLY:
          // Start from Monday of current week
          final monday = now.subtract(Duration(days: now.weekday - 1));
          _startDate = DateTime(monday.year, monday.month, monday.day);
          _endDate = monday.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case BudgetPeriod.MONTHLY:
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case BudgetPeriod.QUARTERLY:
          final quarterMonth = ((now.month - 1) ~/ 3) * 3;
          _startDate = DateTime(now.year, quarterMonth + 1, 1);
          _endDate = DateTime(now.year, quarterMonth + 4, 0, 23, 59, 59);
          break;
        case BudgetPeriod.YEARLY:
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
        case BudgetPeriod.CUSTOM:
          // Keep current dates, user will pick manually
          break;
      }
    });
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _startDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to create a budget.')),
      );
      return;
    }

    // Validate category for category-specific budgets
    if (_selectedType == BudgetType.CATEGORY && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category for category-specific budgets.')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    setState(() => _submitting = true);
    try {
      await BudgetService.createBudget(
        userId: user.uid,
        name: name,
        amount: amount,
        startDate: _startDate,
        endDate: _endDate,
        categoryId: _selectedCategory?.id,
        type: _selectedType,
        period: _selectedPeriod,
      );
      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget "${name}" created successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Return true to indicate success
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      
      // Show user-friendly error message
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  DateTime get now => DateTime.now();

  @override
  void initState() {
    super.initState();
    _updateTypeAndDateRange();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Budget'),
        actions: [
          IconButton(
            icon: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            onPressed: _submitting ? null : _submit,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Budget Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  hintText: 'e.g., Monthly Food Budget',
                ),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a budget name';
                  }
                  if (v.trim().length > 100) {
                    return 'Budget name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Budget Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '\$',
                  hintText: '0.00',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) {
                    return 'Enter a positive amount';
                  }
                  if (value > 1000000) {
                    return 'Amount cannot exceed \$1,000,000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Budget Type
              DropdownButtonFormField<BudgetType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Budget Type',
                ),
                items: BudgetType.values.map((type) {
                  String label;
                  switch (type) {
                    case BudgetType.OVERALL:
                      label = 'Overall Spending';
                      break;
                    case BudgetType.CATEGORY:
                      label = 'Category-Specific';
                      break;
                  }
                  return DropdownMenuItem(
                    value: type,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Category Selection (only for category-specific budgets)
              if (_selectedType == BudgetType.CATEGORY) ...[
                CategoryPicker(
                  categories: widget.categories,
                  selectedCategory: _selectedCategory,
                  onChanged: (Category? newValue) {
                    setState(() => _selectedCategory = newValue);
                  },
                  label: 'Select Category',
                ),
                const SizedBox(height: 12),
              ],

              // Budget Period
              DropdownButtonFormField<BudgetPeriod>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Budget Period',
                ),
                items: BudgetPeriod.values.map((period) {
                  String label;
                  switch (period) {
                    case BudgetPeriod.WEEKLY:
                      label = 'Weekly';
                      break;
                    case BudgetPeriod.MONTHLY:
                      label = 'Monthly';
                      break;
                    case BudgetPeriod.QUARTERLY:
                      label = 'Quarterly';
                      break;
                    case BudgetPeriod.YEARLY:
                      label = 'Yearly';
                      break;
                    case BudgetPeriod.CUSTOM:
                      label = 'Custom';
                      break;
                  }
                  return DropdownMenuItem(
                    value: period,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPeriod = value;
                      _updateTypeAndDateRange();
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Start Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Start: ${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickStartDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick Start Date'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // End Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'End: ${_endDate.year}-${_endDate.month.toString().padLeft(2, '0')}-${_endDate.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickEndDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick End Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.check),
                label: const Text('Create Budget'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

