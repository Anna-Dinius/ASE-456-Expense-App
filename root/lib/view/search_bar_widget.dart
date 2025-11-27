import 'package:flutter/material.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/transaction_list.dart';

class SearchBarWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final Function deleteTx;
  final List<Category> categories;

  const SearchBarWidget({
    required this.transactions,
    required this.deleteTx,
    required this.categories,
    super.key,
  });

  @override
  SearchBarWidgetState createState() => SearchBarWidgetState();
}

class SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = TextEditingController();
  late List<Transaction> _filteredTransactions;
  String _query = '';
  String _selectedCategory = '';
  String _selectedOrder = 'Ascend';
  String _selectedSortBy = 'Date';

  @override
  void initState() {
    super.initState();
    _filteredTransactions = widget.transactions;
  }

  @override //This handles a bug where the transactions wouldn't show up at the start.
  void didUpdateWidget(covariant SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.transactions != widget.transactions) {
      setState(() {
        _filteredTransactions = widget.transactions;
      });
    }
  }

  void _filterTransactions() {
    final lowerQuery = _query.toLowerCase();
    late List<Transaction> unsortedTransactions;

    setState(() {
      unsortedTransactions = widget.transactions.where((tx) {
        return tx.title.toLowerCase().contains(lowerQuery) &&
            widget.categories
                .firstWhere((category) => category.id == tx.categoryId)
                .title
                .contains(_selectedCategory);
      }).toList();
      if (_selectedSortBy == 'Date') {
        unsortedTransactions.sort((a, b) {
          return a.date.compareTo(b.date);
        });
      }
      if (_selectedSortBy == 'Amount') {
        unsortedTransactions.sort((a, b) {
          return a.amount.compareTo(b.amount);
        });
      }

      if (_selectedOrder == 'Descend') {
        unsortedTransactions = unsortedTransactions.reversed.toList();
      }

      _filteredTransactions = unsortedTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Row(children: [
          Expanded(
              child: Padding(
            padding: EdgeInsetsGeometry.all(5),
            child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search transactions',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (input) {
                  _query = input;
                  _filterTransactions();
                }),
          )),
          DropdownButton(
              padding: EdgeInsets.all(5),
              value: _selectedSortBy,
              items: <String>['Date', 'Amount'].map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSortBy = newValue!;
                  _filterTransactions();
                });
              }),
          DropdownButton(
              padding: EdgeInsets.all(5),
              value: _selectedOrder,
              items: <String>['Ascend', 'Descend'].map((String value) {
                return DropdownMenuItem(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedOrder = newValue!;
                  _filterTransactions();
                });
              }),
        ]),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: widget.categories.map((cat) {
            return ChoiceChip(
              label: Text(cat.title),
              selected: _selectedCategory == cat.title,
              onSelected: (bool selected) {
                setState(() => _selectedCategory = selected ? cat.title : '');
                _filterTransactions();
              },
            );
          }).toList(),
        ),

        // Filtered transaction list
        TransactionList(
          _filteredTransactions,
          widget.deleteTx,
          widget.categories,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
