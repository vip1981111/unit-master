import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/account_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  AccountModel? _fromAccount;
  AccountModel? _toAccount;
  DateTime _date = DateTime.now();

  // Default accounts
  final List<AccountModel> _accounts = [
    AccountModel(
      id: 'cash',
      name: 'نقدي',
      nameEn: 'Cash',
      icon: '💵',
      color: const Color(0xFF00D9A5),
      isDefault: true,
    ),
    AccountModel(
      id: 'bank',
      name: 'حساب بنكي',
      nameEn: 'Bank Account',
      icon: '🏦',
      color: const Color(0xFF3A86FF),
    ),
    AccountModel(
      id: 'credit',
      name: 'بطاقة ائتمان',
      nameEn: 'Credit Card',
      icon: '💳',
      color: const Color(0xFF8338EC),
    ),
    AccountModel(
      id: 'savings',
      name: 'مدخرات',
      nameEn: 'Savings',
      icon: '🏧',
      color: const Color(0xFFFFBE0B),
    ),
    AccountModel(
      id: 'investment',
      name: 'استثمارات',
      nameEn: 'Investments',
      icon: '📈',
      color: const Color(0xFF6C63FF),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fromAccount = _accounts.first;
    _toAccount = _accounts[1];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _swapAccounts() {
    setState(() {
      final temp = _fromAccount;
      _fromAccount = _toAccount;
      _toAccount = temp;
    });
  }

  Future<void> _saveTransfer() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(context.read<AppProvider>().isArabic
          ? 'أدخل مبلغ صحيح'
          : 'Enter a valid amount');
      return;
    }

    if (_fromAccount == null || _toAccount == null) {
      _showError(context.read<AppProvider>().isArabic
          ? 'اختر الحسابات'
          : 'Select accounts');
      return;
    }

    if (_fromAccount!.id == _toAccount!.id) {
      _showError(context.read<AppProvider>().isArabic
          ? 'لا يمكن التحويل لنفس الحساب'
          : 'Cannot transfer to same account');
      return;
    }

    final transactionProvider = context.read<TransactionProvider>();
    final appProvider = context.read<AppProvider>();
    final isArabic = appProvider.isArabic;

    // Create two transactions: expense from source and income to destination
    final transferId = const Uuid().v4();

    // Expense from source account
    await transactionProvider.addTransaction(
      title: isArabic
          ? 'تحويل إلى ${_toAccount!.name}'
          : 'Transfer to ${_toAccount!.nameEn}',
      amount: amount,
      type: TransactionType.expense,
      categoryId: 'other',
      note: _noteController.text.isNotEmpty
          ? '${_noteController.text} [Transfer: $transferId]'
          : '[Transfer: $transferId]',
      date: _date,
    );

    // Income to destination account
    await transactionProvider.addTransaction(
      title: isArabic
          ? 'تحويل من ${_fromAccount!.name}'
          : 'Transfer from ${_fromAccount!.nameEn}',
      amount: amount,
      type: TransactionType.income,
      categoryId: 'other_income',
      note: _noteController.text.isNotEmpty
          ? '${_noteController.text} [Transfer: $transferId]'
          : '[Transfer: $transferId]',
      date: _date,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isArabic ? 'تم التحويل بنجاح!' : 'Transfer completed!'),
          backgroundColor: AppTheme.incomeColor,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.expenseColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isArabic = appProvider.isArabic;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  const Text('🔄', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Text(
                    isArabic ? 'تحويل بين الحسابات' : 'Transfer Between Accounts',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Amount Input
              Text(
                isArabic ? 'المبلغ' : 'Amount',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[300],
                  ),
                  prefixText: '${appProvider.currencySymbol} ',
                  prefixStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // From Account
              Text(
                isArabic ? 'من حساب' : 'From Account',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildAccountSelector(
                _fromAccount,
                (account) => setState(() => _fromAccount = account),
                isArabic,
              ),
              const SizedBox(height: 16),

              // Swap Button
              Center(
                child: GestureDetector(
                  onTap: _swapAccounts,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // To Account
              Text(
                isArabic ? 'إلى حساب' : 'To Account',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildAccountSelector(
                _toAccount,
                (account) => setState(() => _toAccount = account),
                isArabic,
              ),
              const SizedBox(height: 24),

              // Date
              Text(
                isArabic ? 'التاريخ' : 'Date',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _date = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        '${_date.day}/${_date.month}/${_date.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Note
              Text(
                isArabic ? 'ملاحظة (اختياري)' : 'Note (Optional)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: isArabic ? 'أضف ملاحظة...' : 'Add a note...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Transfer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.swap_horiz),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'تحويل' : 'Transfer',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSelector(
    AccountModel? selected,
    Function(AccountModel) onSelected,
    bool isArabic,
  ) {
    return InkWell(
      onTap: () => _showAccountPicker(onSelected, isArabic),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected != null ? selected.color : Colors.grey[300]!,
            width: selected != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selected?.color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(selected.icon, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? selected.name : selected.nameEn,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const Icon(Icons.account_balance_wallet_outlined, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isArabic ? 'اختر حساب' : 'Select Account',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAccountPicker(Function(AccountModel) onSelected, bool isArabic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'اختر حساب' : 'Select Account',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(_accounts.length, (index) {
              final account = _accounts[index];
              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: account.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(account.icon, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                title: Text(isArabic ? account.name : account.nameEn),
                onTap: () {
                  onSelected(account);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
