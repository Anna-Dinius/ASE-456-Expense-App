import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:p5_expense/model/category.dart'; // NEW: Import Category model for dropdown
import 'package:p5_expense/view/widgets/category_picker.dart'; // NEW: Import CategoryPicker widget

/// Widget for adding new expense transactions
/// This form allows users to enter transaction details and select a category
class NewTransaction extends StatefulWidget {
  // Function to call when the user submits the form
  final Function addTx;

  // NEW: List of available categories for the user to choose from
  final List<Category> categories;

  NewTransaction(this.addTx, this.categories);

  @override
  _NewTransactionState createState() => _NewTransactionState();
}

class _NewTransactionState extends State<NewTransaction> {
  // Controllers for the text input fields
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // The date the user selected for this transaction
  DateTime _selectedDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // NEW: The category the user selected for this transaction
  // It's nullable (?) because the user might not have selected one yet
  Category? _selectedCategory;

  //NEW: The user can select recurring payments through a check box, and then select an interval
  bool _isRecurring = false;
  String _selectedInterval =
      'Daily'; //Set to Daily as default due to DropDownMenu

  List<DateTime> _pastPayments = [];
  List<DateTime> _futurePayments = [];

  String getNow() {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat("yyyy-MM-dd");
    String formatted = formatter.format(now);
    return formatted;
  }

  /// Validates and submits the form data
  /// This method is called when the user taps "Add Transaction"
  void _submitData() {
    // Get the values from the text fields
    final enteredTitle = _titleController.text;
    final enteredAmountText = _amountController.text;

    // Validate that all required fields are filled
    if (enteredTitle.isEmpty ||
        enteredAmountText.isEmpty ||
        _selectedCategory == null) {
      return; // Don't submit if any validation fails
    }

    // Try to parse the amount, return if invalid
    double? enteredAmount;
    try {
      enteredAmount = double.parse(enteredAmountText);
    } catch (e) {
      return; // Invalid number format
    }

    // Check if amount is positive
    if (enteredAmount <= 0) {
      return; // Amount must be positive
    }
    //Create the dates
    if (_isRecurring) {
      DateTime current = _selectedDate;
      while (current.isBefore(_endDate) || current.isAtSameMomentAs(_endDate)) {
        if (current.isBefore(DateTime.now())) {
          _pastPayments.add(current);
        } else if (current.isAfter(DateTime.now())) {
          _futurePayments.add(current);
        }

        // Increment based on interval
        switch (_selectedInterval) {
          case 'Daily':
            current = current.add(Duration(days: 1));
            break;
          case 'Weekly':
            current = current.add(Duration(days: 7));
            break;
          case 'Monthly':
            current = DateTime(current.year, current.month + 1, current.day);
            break;
        }
      }
    }

    // Call the parent's addTx function with all the form data
    // NEW: Include the selected category ID
    // NEW: Included isRecurring and selectedInterval
    widget.addTx(
        enteredTitle,
        enteredAmount,
        _selectedDate,
        _selectedCategory!.id, // Use ! to tell Dart we know it's not null
        _isRecurring,
        _selectedInterval,
        _pastPayments,
        _futurePayments);

    // Close the modal and return to the main screen
    Navigator.of(context).pop();
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2019),
      lastDate: DateTime(
        DateTime.now().year + 5,
        DateTime.now().month,
        DateTime.now().day,
      ), //The user can select up to 5 years in the future from today.
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    });
    print('...');
  }

  void _endDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _selectedDate,
      lastDate: DateTime(
        _selectedDate.year + 5,
        _selectedDate.month,
        _selectedDate.day,
      ), //The user can select up to 5 years in the future from today.
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _endDate = pickedDate;
      });
    });
    print('...');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
          padding: EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: 'Title'),
                  controller: _titleController,
                  onSubmitted: (_) => _submitData(),
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _submitData(),
                ),
                //NEW: Recurring Payment Toggle
                CheckboxListTile(
                    title: Text('Recurring Payment'),
                    checkColor: Colors.white,
                    value: _isRecurring,
                    onChanged: (bool? value) {
                      setState(() {
                        _isRecurring = value!;
                      });
                    }),
                //If the user selected recurring payment, they can now select an interval
                if (_isRecurring)
                  DropdownButton(
                      value: _selectedInterval,
                      items: <String>['Daily', 'Weekly', 'Monthly']
                          .map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedInterval = newValue!;
                        });
                      }),
                // NEW: Category Selection using CategoryPicker
                // This allows users to choose which category their expense belongs to
                CategoryPicker(
                  categories: widget.categories,
                  selectedCategory: _selectedCategory,
                  onChanged: (Category? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  label: 'Category',
                ),
                // Date Selection
                Container(
                  height: 35,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Picked Date: ${DateFormat.yMd().format(_selectedDate)}',
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor: Theme.of(context).primaryColor),
                        child: Text(
                          'Choose Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: _presentDatePicker,
                      ),
                    ],
                  ),
                ),
                if (_isRecurring)
                  Container(
                    height: 35,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            'End Date: ${DateFormat.yMd().format(_endDate)}',
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor),
                          child: Text(
                            'Choose Date',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: _endDatePicker,
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ElevatedButton(
                    child: Text('Add Transaction'),
                    onPressed: _submitData,
                  ),
                )
              ],
            ),
          )),
    );
  }
}
