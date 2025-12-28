import 'package:budget_manager/models/transaction.dart' as budget_transaction;
import 'package:budget_manager/services/auth_service.dart';
import 'package:budget_manager/services/transaction_service.dart';
import 'package:budget_manager/services/firestore_service.dart';
import 'package:budget_manager/models/goal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:budget_manager/utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isExpense = true;
  String _selectedCategory = 'Alimentation';
  List<Goal> _goals = [];
  String? _selectedGoalId;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    final userId = authService.currentUser!.uid;
    final goals = await firestoreService.getGoals(userId);
    setState(() {
      _goals = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.defaultCategories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'] as String,
                    child: Row(
                      children: [
                        Icon(
                          IconData(category['icon'] as int,
                              fontFamily: 'MaterialIcons'),
                          color: Color(category['color'] as int),
                        ),
                        const SizedBox(width: 8),
                        Text(category['name'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              if (!_isExpense) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedGoalId,
                  decoration: const InputDecoration(
                    labelText: 'Allouer à un objectif (optionnel)',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Aucun objectif'),
                    ),
                    ..._goals.map((goal) {
                      return DropdownMenuItem<String>(
                        value: goal.id,
                        child: Text(goal.name),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGoalId = value;
                    });
                  },
                ),
              ],
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SwitchListTile(
                title: const Text('Expense'),
                value: _isExpense,
                onChanged: (value) {
                  setState(() {
                    _isExpense = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child:
                        Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  ),
                  TextButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _selectedDate) {
                        print('Date selected: $picked');
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: const Text('Select Date'),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Time: ${_selectedTime.format(context)}'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null && picked != _selectedTime) {
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                    child: const Text('Select Time'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final authService =
                        Provider.of<AuthService>(context, listen: false);
                    final transactionService =
                        Provider.of<TransactionService>(context, listen: false);
                    final firestoreService =
                        Provider.of<FirestoreService>(context, listen: false);

                    if (authService.currentUser != null) {
                      final amount = double.parse(_amountController.text);
                      final newTransaction = budget_transaction.Transaction(
                        id: const Uuid().v4(),
                        userId: authService.currentUser!.uid,
                        title: _titleController.text,
                        description: '',
                        amount: amount,
                        category: _selectedCategory,
                        date: DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          _selectedTime.hour,
                          _selectedTime.minute,
                        ),
                        isExpense: _isExpense,
                      );

                      await transactionService.addTransaction(newTransaction);

                      // If it's income and a goal is selected, allocate to goal
                      if (!_isExpense && _selectedGoalId != null) {
                        final goal =
                            _goals.firstWhere((g) => g.id == _selectedGoalId);
                        final updatedGoal = goal.copyWith(
                          currentAmount: goal.currentAmount + amount,
                        );
                        await firestoreService.updateGoal(
                            goal.id, updatedGoal.toMap());
                      }

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } else {
                      // Handle the case where the user is not logged in, e.g., show a snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please log in to add a transaction.')),
                      );
                    }
                  }
                },
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
