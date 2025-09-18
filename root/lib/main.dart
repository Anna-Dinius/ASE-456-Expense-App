import 'package:p5_expense/theme/main_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;


import 'package:p5_expense/view/new_transaction.dart';
import 'package:p5_expense/view/transaction_list.dart';
import 'package:p5_expense/view/chart.dart';
import 'package:p5_expense/model/transaction.dart';

const TEST_USER_ID = 'quldUwy6wtd5LCKLE2Uc';

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
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Transaction> _userTransactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final transactions = await getAllTransactions(TEST_USER_ID);
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

  Future<void> _addNewTransaction(
      String txTitle, double txAmount, DateTime chosenDate) async {

    final txId = firestore.FirebaseFirestore.instance.collection('users').doc(TEST_USER_ID).collection('transactions').doc().id;
   
   final newTx = Transaction(
      id: txId,
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
    );

    setState(() {
      _userTransactions.add(newTx);
    });

    await firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(TEST_USER_ID)
        .collection('transactions')
        .doc(newTx.id)
        .set({
      'title': txTitle,
      'amount': txAmount,
      'date': chosenDate
    });
  }

  void _startAddNewTransaction(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return NewTransaction(_addNewTransaction);
      },
    );
  }

  void _deleteTransaction(String id) {
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
    });

    firestore.FirebaseFirestore.instance
        .collection('users')
        .doc(TEST_USER_ID)
        .collection('transactions')
        .doc(id)
        .delete();
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
            TransactionList(_userTransactions, _deleteTransaction),
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
