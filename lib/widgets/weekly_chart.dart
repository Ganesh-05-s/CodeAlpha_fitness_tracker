import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/activity_provider.dart';
import '../theme/app_theme.dart';

class WeeklyProgressChart extends StatelessWidget {
  final List<DailyChartData> chartData;

  const WeeklyProgressChart({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    // Find maximum calories to scale Y-axis
    double maxCalories = 600;
    for (var data in chartData) {
      if (data.totalCalories > maxCalories) {
        maxCalories = data.totalCalories.toDouble();
      }
    }
    // Round maxCalories to next 200
    maxCalories = ((maxCalories / 200).ceil() * 200).toDouble();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(10, 20, 15, 10),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxCalories,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => const Color(0xFF1E293B),
              tooltipBorder: const BorderSide(color: Colors.white10, width: 1),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipBorderRadius: BorderRadius.circular(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dayData = chartData[groupIndex];
                return BarTooltipItem(
                  '${dayData.dayName}\n',
                  const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: '${dayData.totalCalories} kcal\n',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    TextSpan(
                      text: 'Workout: ${dayData.workoutCalories} kcal\nSteps: ${dayData.stepsCalories} kcal',
                      style: const TextStyle(
                        color: AppTheme.accentLavender,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < chartData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        chartData[index].dayName,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) return const SizedBox();
                  return Text(
                    '${value.toInt()} kcal',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.08),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: List.generate(chartData.length, (index) {
            final data = chartData[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.totalCalories.toDouble(),
                  gradient: const LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.accentLavender,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 14,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: maxCalories,
                    color: Colors.grey.withOpacity(0.05),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
