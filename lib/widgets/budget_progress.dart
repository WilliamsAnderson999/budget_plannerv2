import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:budget_manager/theme/app_theme.dart';

class BudgetProgress extends StatelessWidget {
  final String title;
  final double currentAmount;
  final double targetAmount;
  final Color color;
  final IconData icon;

  const BudgetProgress({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
        (currentAmount / targetAmount * 100).clamp(0, 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBlack,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${currentAmount.toStringAsFixed(2)} / \$${targetAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: currentAmount / targetAmount,
            backgroundColor: Colors.white.withOpacity(0.40),
            progressColor: color,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }
}
