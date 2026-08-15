class ParsedCommand {
  final String type;
  final double amount;

  const ParsedCommand({required this.type, required this.amount});
}

/// Parses a command of the form `<expense_type> <expense_amount>`,
/// e.g. `fare 60`. Throws a [FormatException] with a user-facing
/// message when the command is malformed.
ParsedCommand parseCommand(String input) {
  final tokens = input.trim().split(RegExp(r'\s+'));

  if (tokens.length != 2 || tokens.any((t) => t.isEmpty)) {
    throw const FormatException(
      'Command must look like: <type> <amount>, e.g. "fare 60"',
    );
  }

  final type = tokens[0];
  final amount = double.tryParse(tokens[1]);

  if (amount == null || amount <= 0) {
    throw const FormatException('Amount must be a positive number');
  }

  return ParsedCommand(type: type, amount: amount);
}
