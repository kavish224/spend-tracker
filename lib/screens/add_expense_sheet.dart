import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  String category = 'Food';
  String paymentMethod = 'UPI';
  bool _isSubmitting = false;

  final categories = const ['Food', 'Groceries', 'Fuel', 'Rent', 'Shopping'];
  final payments = const ['Cash', 'UPI', 'Credit Card', 'Bank'];

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Expense',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'e.g. 499',
                  prefixText: '₹ ',
                  filled: true,
                  fillColor: const Color(0xFF202020),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  final amount = double.tryParse(raw.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  filled: true,
                  fillColor: const Color(0xFF202020),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (val) => setState(() => category = val ?? category),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: paymentMethod,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  filled: true,
                  fillColor: const Color(0xFF202020),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: payments
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: _isSubmitting
                    ? null
                    : (val) =>
                          setState(() => paymentMethod = val ?? paymentMethod),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: noteController,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  hintText: 'Add details',
                  filled: true,
                  fillColor: const Color(0xFF202020),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          final amount = double.parse(
                            amountController.text.trim().replaceAll(',', '.'),
                          );
                          final navigator = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);

                          setState(() => _isSubmitting = true);
                          try {
                            await provider.addExpense(
                              Expense(
                                amount: amount,
                                category: category,
                                paymentMethod: paymentMethod,
                                note: noteController.text.trim().isEmpty
                                    ? null
                                    : noteController.text.trim(),
                                date: DateTime.now(),
                              ),
                            );
                            if (!mounted) return;
                            navigator.pop();
                          } catch (_) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Unable to add expense.'),
                              ),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Expense'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
