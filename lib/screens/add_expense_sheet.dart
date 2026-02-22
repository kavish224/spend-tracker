import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_providers.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final amountController = TextEditingController();
  String category = "Food";
  String paymentMethod = "UPI";

  final categories = ["Food", "Groceries", "Fuel", "Rent", "Shopping"];
  final payments = ["Cash", "UPI", "Credit Card", "Bank"];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter amount",
              ),
            ),
            DropdownButton<String>(
              value: category,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => category = val!),
            ),
            DropdownButton<String>(
              value: paymentMethod,
              items: payments
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: (val) => setState(() => paymentMethod = val!),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount == 0) return;

                await provider.addExpense(
                  Expense(
                    amount: amount,
                    category: category,
                    paymentMethod: paymentMethod,
                    date: DateTime.now(),
                  ),
                );

                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        ),
      ),
    );
  }
}