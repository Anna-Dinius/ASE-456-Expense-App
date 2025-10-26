import 'package:flutter/material.dart';

/// A simple, non-functional skeleton for the Savings Summary screen.
/// Currently displays a placeholder message indicating there are no goals.
class SavingsSummaryScreen extends StatelessWidget {
  const SavingsSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.savings_outlined,
                size: 64,
                // Use the app's primary color directly to match theme and avoid pinkish tint
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'No savings goals yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create a goal to start tracking your savings.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
