import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import '../providers/app_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';
import '../widgets/quick_actions.dart';
import 'add_transaction_screen.dart';
import 'all_transactions_screen.dart';
import 'transfer_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final isArabic = appProvider.isArabic;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'مصروفي' : 'Masroofy',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Notifications
                },
              ),
            ],
          ),

          // Balance Card
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BalanceCard(
                balance: transactionProvider.balance,
                income: transactionProvider.totalIncome,
                expense: transactionProvider.totalExpense,
                currencySymbol: appProvider.currencySymbol,
                isArabic: isArabic,
              ),
            ),
          ),

          // Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: QuickActions(
                isArabic: isArabic,
                onAddExpense: () => _showAddTransaction(context, TransactionType.expense),
                onAddIncome: () => _showAddTransaction(context, TransactionType.income),
                onTransfer: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const TransferScreen(),
                  );
                },
              ),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isArabic ? 'آخر المعاملات' : 'Recent Transactions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllTransactionsScreen(),
                        ),
                      );
                    },
                    child: Text(isArabic ? 'عرض الكل' : 'View All'),
                  ),
                ],
              ),
            ),
          ),

          // Transactions List
          if (transactionProvider.transactions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '📝',
                      style: TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isArabic ? 'لا توجد معاملات بعد' : 'No transactions yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'اضغط + لإضافة معاملة جديدة'
                          : 'Tap + to add a new transaction',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final transaction =
                      transactionProvider.recentTransactions[index];
                  final category = transactionProvider.getCategoryById(
                    transaction.categoryId,
                    isIncome: transaction.type ==
                        TransactionType.income,
                  );

                  return TransactionItem(
                    transaction: transaction,
                    category: category,
                    currencySymbol: appProvider.currencySymbol,
                    isArabic: isArabic,
                    onTap: () {
                      // TODO: Transaction details
                    },
                    onDelete: () {
                      transactionProvider.deleteTransaction(transaction.id);
                    },
                  );
                },
                childCount: transactionProvider.recentTransactions.length,
              ),
            ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context, TransactionType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionScreen(initialType: type),
    );
  }
}
