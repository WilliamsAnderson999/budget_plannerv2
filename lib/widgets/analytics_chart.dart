import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:budget_manager/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AnalyticsChart extends StatelessWidget {
  final String period;
  final List<ChartData> data;

  const AnalyticsChart({
    super.key,
    required this.period,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        majorGridLines: const MajorGridLines(width: 0),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      primaryYAxis: NumericAxis(
        numberFormat: NumberFormat.currency(symbol: '\$'),
        majorGridLines: MajorGridLines(
          color: AppTheme.surfaceBlack,
          width: 1,
        ),
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
        labelStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      series: <CartesianSeries<ChartData, String>>[
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.income,
          name: 'Revenus',
          color: AppTheme.incomeColor,
          borderRadius: BorderRadius.circular(4),
          width: 0.6,
        ),
        ColumnSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData sales, _) => sales.x,
          yValueMapper: (ChartData sales, _) => sales.expense,
          name: 'Dépenses',
          color: AppTheme.expenseColor,
          borderRadius: BorderRadius.circular(4),
          width: 0.6,
        ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        header: '',
        format: 'point.x : point.y\$',
        color: AppTheme.cardBlack,
        textStyle: TextStyle(color: AppTheme.textPrimary, fontSize: 12),
      ),
    );
  }
}

class ChartData {
  final String x;
  final double income;
  final double expense;

  ChartData(this.x, this.income, this.expense);
}
