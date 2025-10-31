import 'package:flutter/material.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart';
import 'package:p5_expense/view/transaction_list.dart';
class SearchBarWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final Function deleteTx;
  final List<Category> categories;

  SearchBarWidget({
    required this.transactions,
    required this.deleteTx,
    required this.categories,
  });

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _searchController = TextEditingController();
  late List<Transaction> _filteredTransactions;
  String _selectedCategory = '';

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

  void _filterTransactions(String query) {
    final lowerQuery = query.toLowerCase();

    setState(() {
      _filteredTransactions = widget.transactions.where((tx) {

        return tx.title.toLowerCase().contains(lowerQuery) ||
               tx.amount.toString().contains(lowerQuery) ||
               widget.categories.firstWhere((category) => category.id == tx.categoryId).title.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search transactions',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: _filterTransactions,
          ),
        ),
        Wrap(
          spacing: 8,
          children: widget.categories.map((cat) {
            return ChoiceChip(
              label: Text(cat.title),
              selected: _selectedCategory == cat.title,
              onSelected: (bool selected) {
                setState(() => _selectedCategory = selected ? cat.title : '');
                _filterTransactions(_selectedCategory);
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
