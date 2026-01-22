import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  final bool isArabic;
  final VoidCallback? onAddExpense;
  final VoidCallback? onAddIncome;
  final VoidCallback? onTransfer;

  const QuickActions({
    super.key,
    required this.isArabic,
    this.onAddExpense,
    this.onAddIncome,
    this.onTransfer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.arrow_upward,
            label: isArabic ? 'مصروف' : 'Expense',
            color: AppTheme.expenseColor,
            onTap: onAddExpense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.arrow_downward,
            label: isArabic ? 'دخل' : 'Income',
            color: AppTheme.incomeColor,
            onTap: onAddIncome,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.swap_horiz,
            label: isArabic ? 'تحويل' : 'Transfer',
            color: AppTheme.primaryColor,
            onTap: onTransfer,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
