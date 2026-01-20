import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../utils/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool isIncome;
  final Transaction? editTransaction;

  const AddTransactionScreen({
    super.key,
    this.isIncome = false,
    this.editTransaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _noteController = TextEditingController();

  late bool _isIncome;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _isIncome = widget.isIncome;

    if (widget.editTransaction != null) {
      final t = widget.editTransaction!;
      _amountController.text = t.amount.toString();
      _descriptionController.text = t.description;
      _noteController.text = t.note ?? '';
      _isIncome = t.isIncome;
      _selectedDate = t.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransaction != null ? 'تعديل المعاملة' : 'إضافة معاملة'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          final categories = _isIncome
              ? provider.incomeCategories
              : provider.expenseCategories;

          // Set default category if not selected
          if (_selectedCategory == null && categories.isNotEmpty) {
            _selectedCategory = categories.first;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Transaction Type Toggle
                _buildTypeToggle(),
                const SizedBox(height: 24),

                // Amount
                _buildAmountField(),
                const SizedBox(height: 16),

                // Description
                _buildDescriptionField(),
                const SizedBox(height: 16),

                // Category
                _buildCategorySelector(categories),
                const SizedBox(height: 16),

                // Date
                _buildDateSelector(),
                const SizedBox(height: 16),

                // Note
                _buildNoteField(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isIncome ? AppTheme.expenseColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'مصروف',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !_isIncome ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isIncome = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isIncome ? AppTheme.incomeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'دخل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _isIncome ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'المبلغ',
        prefixIcon: Icon(Icons.attach_money),
        hintText: '0.00',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال المبلغ';
        }
        if (double.tryParse(value) == null) {
          return 'يرجى إدخال رقم صحيح';
        }
        if (double.parse(value) <= 0) {
          return 'يجب أن يكون المبلغ أكبر من صفر';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'الوصف',
        prefixIcon: Icon(Icons.description),
        hintText: 'مثال: وجبة غداء',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'يرجى إدخال وصف';
        }
        return null;
      },
    );
  }

  Widget _buildCategorySelector(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'التصنيف',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategory?.id == category.id ||
                (_selectedCategory == null && category == categories.first);

            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? category.color : category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: category.color,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: isSelected ? Colors.white : category.color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.nameAr,
                      style: TextStyle(
                        color: isSelected ? Colors.white : category.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'التاريخ',
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat('dd/MM/yyyy').format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'ملاحظات (اختياري)',
        prefixIcon: Icon(Icons.note),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSaveButton(ExpenseProvider provider) {
    return ElevatedButton(
      onPressed: () => _saveTransaction(provider),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(
        widget.editTransaction != null ? 'حفظ التعديلات' : 'إضافة المعاملة',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction(ExpenseProvider provider) {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار تصنيف')),
      );
      return;
    }

    final transaction = Transaction(
      id: widget.editTransaction?.id,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      date: _selectedDate,
      categoryId: _selectedCategory!.id!,
      type: _isIncome ? TransactionType.income : TransactionType.expense,
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
    );

    if (widget.editTransaction != null) {
      provider.updateTransaction(transaction);
    } else {
      provider.addTransaction(transaction);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.editTransaction != null
              ? 'تم تحديث المعاملة بنجاح'
              : 'تم إضافة المعاملة بنجاح',
        ),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
