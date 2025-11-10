import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/model/savings_goal.dart';
import 'package:p5_expense/service/savings_goal_service.dart';

class EditSavingsGoalScreen extends StatefulWidget {
  final SavingsGoal goal;
  const EditSavingsGoalScreen({super.key, required this.goal});

  @override
  State<EditSavingsGoalScreen> createState() => _EditSavingsGoalScreenState();
}

class _EditSavingsGoalScreenState extends State<EditSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _targetAmountController;
  late final TextEditingController _currentAmountController;
  late final TextEditingController _descriptionController;
  DateTime? _targetDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal.title);
    _targetAmountController = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(2),
    );
    _currentAmountController = TextEditingController(
      text: widget.goal.currentAmount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.goal.description ?? '',
    );
    _targetDate = widget.goal.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = fb_auth.FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to edit a goal.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final targetAmount = double.parse(_targetAmountController.text.trim());
      final currentAmount = double.parse(_currentAmountController.text.trim());
      
      var updated = widget.goal.copyWith(
        title: _titleController.text.trim(),
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        targetDate: _targetDate,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        completed: currentAmount >= targetAmount && targetAmount > 0,
      );
      
      updated = updated.updateMilestones();
      
      await SavingsGoalService.updateGoal(user.uid, updated);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update goal: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Savings Goal'),
        actions: [
          IconButton(
            icon: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _submitting ? null : _submit,
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Goal title'),
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(labelText: 'Target amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value <= 0) {
                    return 'Enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _currentAmountController,
                decoration: const InputDecoration(labelText: 'Current amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final value = double.tryParse(v?.trim() ?? '');
                  if (value == null || value < 0) {
                    return 'Enter an amount 0 or greater';
                  }
                  final target = double.tryParse(_targetAmountController.text.trim()) ?? 0.0;
                  if (target > 0 && value > target) {
                    return 'Current amount cannot exceed target';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _targetDate == null
                          ? 'No target date'
                          : 'Target: ${_targetDate!.year}-${_targetDate!.month.toString().padLeft(2, '0')}-${_targetDate!.day.toString().padLeft(2, '0')}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Pick date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.check),
                label: const Text('Save changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
