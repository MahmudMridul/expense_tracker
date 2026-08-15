import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/expense_list_item.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().load();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _controller.text;
    if (input.trim().isEmpty) return;
    final provider = context.read<ExpenseProvider>();
    try {
      await provider.submitCommand(input);
      _controller.clear();
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _close() async {
    await context.read<ExpenseProvider>().closeCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenses = provider.currentPeriod?.expenses ?? [];
          final total = provider.currentPeriod?.total ?? 0;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  formatBdt(total),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(child: Text('No expenses yet'))
                    : ListView.builder(
                        itemCount: expenses.length,
                        itemBuilder: (context, index) =>
                            ExpenseListItem(expense: expenses[index]),
                      ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'e.g. fare 60',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _submit(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        tooltip: 'Add expense',
                        onPressed: _submit,
                      ),
                      const SizedBox(width: 4),
                      OutlinedButton(
                        onPressed: expenses.isEmpty ? null : _close,
                        child: const Text('close'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
