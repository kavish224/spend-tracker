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

  /// Map for DB update (excludes id to avoid touching primary key).
  Map<String, dynamic> toMapForUpdate() {
    return {
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: _toDouble(map['amount']),
      category: (map['category'] ?? 'Other').toString(),
      paymentMethod: (map['paymentMethod'] ?? 'Unknown').toString(),
      date: _toDateTime(map['date']),
      note: map['note']?.toString(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _toDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
