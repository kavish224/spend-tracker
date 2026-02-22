import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_providers.dart';
import 'add_expense_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Spend Tracker")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const AddExpenseSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "₹ ${provider.monthlyTotal.toStringAsFixed(0)}",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: provider.expenses.length,
                itemBuilder: (_, i) {
                  final e = provider.expenses[i];
                  return ListTile(
                    title: Text(e.category),
                    subtitle: Text(e.paymentMethod),
                    trailing: Text("₹${e.amount}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}