import 'theme/main_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// Added Firebase Auth + our services and profile screens
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:p5_expense/service/auth_service.dart';
import 'package:p5_expense/service/user_service.dart';
import 'package:p5_expense/view/profile_creation.dart';
import 'package:p5_expense/view/profile_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

import 'package:p5_expense/view/new_transaction.dart';
import 'package:p5_expense/view/transaction_list.dart';
import 'package:p5_expense/view/chart.dart';
import 'package:p5_expense/view/manage_categories.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart'; // NEW: Import the Category model
import 'package:p5_expense/service/category_service.dart'; // NEW: Import CategoryService

// Removed hardcoded TEST_USER_ID; using FirebaseAuth current user instead

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Expenses',
      theme: mainTheme,
      // Show sign-up when signed out, otherwise the main app
      home: AuthGate(),
    );
  }
}

// MyHomePage now receives the signed-in user's uid so we can load
// categories and transactions from their own subcollections.
class MyHomePage extends StatefulWidget {
  final String userId;
  MyHomePage({required this.userId});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];

  // NEW: List to store all available categories
  // We start with the default categories, but users can add/edit/delete them later
  final List<Category> _categories = List.from(DefaultCategories.categories);

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initializes the app by loading data and seeding default categories if needed
  Future<void> _initializeApp() async {
    try {
      // Seed default categories if none exist for this user
      await CategoryService.seedDefaultCategories(widget.userId);

      // Migrate legacy transactions to have categoryId for this user
      await CategoryService.migrateLegacyTransactions(widget.userId);

      // Load categories and transactions
      await loadCategories();
      await loadTransactions();
    } catch (e) {
      print('Error initializing app: $e');
      // Still try to load data even if initialization fails
      await loadCategories();
      await loadTransactions();
    }
  }

  /// Loads categories from Firebase for this user
  Future<void> loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories(widget.userId);
      setState(() {
        _categories.clear();
        _categories.addAll(categories);
      });
    } catch (e) {
      print('Error loading categories: $e');
      // Keep default categories as fallback
    }
  }

  Future<void> loadTransactions() async {
    final transactions = await getAllTransactions(widget.userId);
    setState(() {
      _userTransactions = transactions;
    });
  }

  // APIs
  List<Transaction> get _recentTransactions {
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  /// Adds a new transaction to the list
  /// This method is called when the user submits the "Add Transaction" form
  ///
  /// NEW: Now requires a categoryId parameter to categorize the expense
  Future<void> _addNewTransaction(
      String txTitle,
      double txAmount,
      DateTime chosenDate,
      String categoryId,
      bool recurring,
      String interval,
      List<DateTime> pastPayments,
      List<DateTime> futurePayments) async {
    final txId = firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('transactions')
        .doc()
        .id;

    final newTx = Transaction(
      id: txId,
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      categoryId: categoryId, // NEW: Include the selected category
      recurring: recurring, //NEW: Include recurring and interval
      interval: interval,
      pastPayments: pastPayments,
      futurePayments: futurePayments,
    );

    setState(() {
      _userTransactions.add(newTx);
    });

    await firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('transactions')
        .doc(newTx.id)
        .set({
      'title': txTitle,
      'amount': txAmount,
      'date': chosenDate,
      'categoryId':
          categoryId, // NEW: Include category information in Firestore
      'recurring': recurring,
      'interval': interval,
      'pastPayments': pastPayments,
      'futurePayments': futurePayments,
    });
  }

  /// Shows the "Add Transaction" form in a modal bottom sheet
  /// This is called when the user taps the "+" button
  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        // NEW: Pass the categories list to the form so users can select from them
        return NewTransaction(_addNewTransaction, _categories);
      },
    );
  }

  /// Shows the "Manage Categories" screen
  /// This is called when the user taps the category icon in the app bar
  void _showManageCategories(BuildContext ctx) {
    Navigator.of(ctx).push(
      MaterialPageRoute(
        builder: (_) => ManageCategoriesScreen(
          categories: _categories,
          onCategoriesChanged: refreshCategories,
          userId: widget.userId,
        ),
      ),
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });

    firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('transactions')
        .doc(id)
        .delete();
  }

  /// Refreshes categories after they've been modified
  /// This is called when categories are added, edited, or deleted
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  Future<List<Transaction>> getAllTransactions(String userId) async {
    final transactions = await firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .get();

    return transactions.docs
        .map((doc) => Transaction.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Personal Expenses',
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () => _showManageCategories(context),
          ),
          // Open Profile summary (with debug copy button) for current user
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfileSummaryScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Chart(_recentTransactions),
            // NEW: Pass the categories list to the transaction list so it can display category info
            TransactionList(_userTransactions, _deleteTransaction, _categories),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
      ),
    );
  }
}

// AuthGate listens to auth changes and decides what to show:
// - If signed out: show ProfileCreationScreen
// - If signed in: ensure user doc exists, then show MyHomePage
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<fb_auth.User?>(
      stream: AuthService.onAuthStateChanged(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) {
          return ProfileCreationScreen();
        }
        // Ensure user document exists (idempotent)
        // Don't default to a placeholder name here. If displayName is null we
        // pass an empty string — the UserService will create the doc and the
        // profile creation flow will later patch the name when available.
        UserService.createUserIfMissing(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
        );
        return MyHomePage(userId: user.uid);
      },
    );
  }
}
