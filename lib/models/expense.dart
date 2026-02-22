class Expense {
  final int? id;
  final double amount;
  final String category;
  final String paymentMethod;
  final DateTime date;
  final String? note;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      amount: map['amount'],
      category: map['category'],
      paymentMethod: map['paymentMethod'],
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }
}