import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../utils/amount_parser.dart';

class AddExpenseSheet extends StatefulWidget {
  const AddExpenseSheet({super.key});

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _category = 'Food';
  String _paymentMethod = 'UPI';
  bool _isSubmitting = false;

  static const List<String> _categories = [
    'Food',
    'Groceries',
    'Fuel',
    'Rent',
    'Shopping',
  ];
  static const List<String> _payments = [
    'Cash',
    'UPI',
    'Credit Card',
    'Bank',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                children: [
                  _buildAmountField(),
                  const SizedBox(height: 16),
                  _buildCategoryPicker(context),
                  const SizedBox(height: 16),
                  _buildPaymentPicker(context),
                  const SizedBox(height: 16),
                  _buildNoteField(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          placeholder: 'e.g. 499',
          prefix: const Padding(
            padding: EdgeInsets.only(left: 14),
            child: Text('₹ ', style: TextStyle(fontSize: 17)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(10),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
          ],
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }

  Widget _buildCategoryPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPicker(
            context: context,
            title: 'Category',
            items: _categories,
            selected: _category,
            onSelected: (v) => setState(() => _category = v),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_category, style: const TextStyle(fontSize: 17)),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: CupertinoColors.inactiveGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _showPicker(
            context: context,
            title: 'Payment Method',
            items: _payments,
            selected: _paymentMethod,
            onSelected: (v) => setState(() => _paymentMethod = v),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_paymentMethod, style: const TextStyle(fontSize: 17)),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22,
                  color: CupertinoColors.inactiveGray,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note (optional)',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        CupertinoTextField(
          controller: _noteController,
          placeholder: 'Add details',
          maxLines: 2,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: CupertinoColors.tertiarySystemFill,
            borderRadius: BorderRadius.circular(10),
          ),
          style: const TextStyle(fontSize: 17),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ExpenseProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 14),
        color: CupertinoColors.systemBlue,
        borderRadius: BorderRadius.circular(12),
        onPressed: _isSubmitting
            ? null
            : () => _submit(provider),
        child: _isSubmitting
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : const Text('Add Expense'),
      ),
    );
  }

  Future<void> _submit(ExpenseProvider provider) async {
    final amount = parseAmount(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context, 'Enter a valid amount');
      return;
    }

    final navigator = Navigator.of(context);

    setState(() => _isSubmitting = true);
    try {
      await provider.addExpense(
        Expense(
          amount: amount,
          category: _category,
          paymentMethod: _paymentMethod,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          date: DateTime.now(),
        ),
      );
      if (!mounted) return;
      navigator.pop();
    } catch (_) {
      if (!mounted) return;
      _showError(context, 'Unable to add expense.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showError(BuildContext context, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPicker({
    required BuildContext context,
    required String title,
    required List<String> items,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    int selectedIndex = items.indexOf(selected);
    if (selectedIndex < 0) selectedIndex = 0;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (pickerContext) => _PickerModal(
        title: title,
        items: items,
        initialIndex: selectedIndex,
        onDone: (index) {
          onSelected(items[index]);
          Navigator.of(pickerContext).pop();
        },
        onCancel: () => Navigator.of(pickerContext).pop(),
      ),
    );
  }

}

class _PickerModal extends StatefulWidget {
  const _PickerModal({
    required this.title,
    required this.items,
    required this.initialIndex,
    required this.onDone,
    required this.onCancel,
  });

  final String title;
  final List<String> items;
  final int initialIndex;
  final ValueChanged<int> onDone;
  final VoidCallback onCancel;

  @override
  State<_PickerModal> createState() => _PickerModalState();
}

class _PickerModalState extends State<_PickerModal> {
  late int _selectedIndex;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _scrollController = FixedExtentScrollController(
      initialItem: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      color: const Color(0xFF1C1C1E),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CupertinoButton(
                onPressed: () => widget.onDone(_selectedIndex),
                child: const Text('Done'),
              ),
            ],
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: _scrollController,
              itemExtent: 36,
              onSelectedItemChanged: (i) => setState(() => _selectedIndex = i),
              children: widget.items
                  .map((s) => Center(child: Text(s)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
