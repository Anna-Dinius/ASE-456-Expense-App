import 'package:p5_expense/view/savings_summary.dart';

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
import 'package:p5_expense/view/chart.dart';
import 'package:p5_expense/view/manage_categories.dart';
import 'package:p5_expense/view/budgets_list.dart';
import 'package:p5_expense/view/charts_overview.dart';
import 'package:p5_expense/view/report_list.dart';
import 'package:p5_expense/model/transaction.dart';
import 'package:p5_expense/model/category.dart'; // NEW: Import the Category model
import 'package:p5_expense/service/category_service.dart'; // NEW: Import CategoryService

import 'package:p5_expense/view/search_bar_widget.dart';

// Removed hardcoded TEST_USER_ID; using FirebaseAuth current user instead

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.userId});
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
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
      await updateRecurringTransactions(widget.userId);
      await loadTransactions();
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // Still try to load data even if initialization fails
      await loadCategories();
      await updateRecurringTransactions(widget.userId);
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
      debugPrint('Error loading categories: $e');
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
  // Note: _recentTransactions removed - Chart widget now uses AnalyticsService directly

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

  //NEW: This functions updates the scheduled and current payments of Transactions in the database
  Future<void> updateRecurringTransactions(userId) async {
    debugPrint('updateRecurringTransactions was called.');
    final today = DateTime.now();
    try {
      final snapshot = await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
      for (final doc in snapshot.docs) {
        final data = doc.data();

        //1. Safely parse data
        final List<dynamic> pastPaymentsRaw = data['pastPayments'] ?? [];
        final List<dynamic> futurePaymentsRaw = data['futurePayments'] ?? [];

        final pastPayments = pastPaymentsRaw
            .map((e) => (e as firestore.Timestamp).toDate())
            .toList();
        final futurePayments = futurePaymentsRaw
            .map((e) => (e as firestore.Timestamp).toDate())
            .toList();
        // 2. Move ALL payments that are due on or before today
        final duePayments = futurePayments
            .where(
              (p) => _isSameDay(p, today) || p.isBefore(today),
            )
            .toList();
        var combinedPayments = pastPayments +
            duePayments; //necessary to handle an edge case where past payment already contains the currently due payment
        debugPrint('combinedPayments: $combinedPayments');
        if (combinedPayments.isNotEmpty) {
          // Keep the last due payment as the new "current date"
          final latestDue = combinedPayments.last;

          // Update lists
          final updatedPast = List<DateTime>.from(pastPayments)
            ..addAll(duePayments);
          final updatedFuture = List<DateTime>.from(futurePayments)
            ..removeWhere((p) => duePayments.contains(p));
          debugPrint('Latest due: $latestDue');
          await doc.reference.update({
            'date': latestDue,
            'pastPayments': updatedPast,
            'futurePayments': updatedFuture,
          });
        }
      }
    } catch (e) {
      debugPrint('Error updating recurring transactions: $e');
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BudgetsListScreen(categories: _categories),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChartsOverviewScreen(),
                ),
              );
            },
            tooltip: 'View Charts',
          ),
          IconButton(
            icon: Icon(Icons.assessment),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReportsListScreen(),
                ),
              );
            },
            tooltip: 'View Reports',
          ),
          IconButton(
            icon: Icon(Icons.savings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SavingsSummaryScreen()),
              );
            },
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
            Chart.withUserId(widget.userId),
            // NEW: Pass the categories list to the transaction list so it can display category info
            SearchBarWidget(
                transactions: _userTransactions,
                deleteTx: _deleteTransaction,
                categories: _categories),
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
  const AuthGate({super.key});

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
