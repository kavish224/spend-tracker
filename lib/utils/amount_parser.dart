/// Parses user-entered amount strings (e.g. "1,200.50", "1200", "1.234,56").
/// Returns null for empty/invalid input.
double? parseAmount(String? input) {
  if (input == null) return null;
  var raw = input.trim().replaceAll(' ', '');
  if (raw.isEmpty) return null;

  final hasComma = raw.contains(',');
  final hasDot = raw.contains('.');
  if (hasComma && hasDot) {
    raw = raw.replaceAll(',', '');
  } else if (hasComma) {
    final commaCount = ','.allMatches(raw).length;
    final looksLikeThousands =
        commaCount > 1 || RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(raw);
    raw = looksLikeThousands
        ? raw.replaceAll(',', '')
        : raw.replaceAll(',', '.');
  }

  final value = double.tryParse(raw);
  if (value == null) return null;
  if (value.isNegative) return null;
  return value;
}
