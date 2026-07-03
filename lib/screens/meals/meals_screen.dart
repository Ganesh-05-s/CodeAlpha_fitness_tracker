import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/meal_provider.dart';
import '../../theme/app_theme.dart';
import 'add_meal_screen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);
    final theme = Theme.of(context);

    final caloriesEaten = mealProvider.todayCaloriesEaten;
    final budget = mealProvider.calorieBudget;
    final caloriesRemaining = (budget - caloriesEaten).clamp(0, budget);
    final carbsEaten = mealProvider.todayCarbsEaten;
    final proteinEaten = mealProvider.todayProteinEaten;
    final fatEaten = mealProvider.todayFatEaten;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Performance Dashboard Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E), // Dark background from screenshot
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calories Remaining',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            '$caloriesRemaining',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Budget: $budget',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Eaten: $caloriesEaten',
                            style: const TextStyle(color: Color(0xFFA1F531), fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMacroIndicator('Carbs', '${(120 - carbsEaten).clamp(0, 120)}g left', carbsEaten / 120, Colors.blue),
                      _buildMacroIndicator('Protein', '${(85 - proteinEaten).clamp(0, 85)}g left', proteinEaten / 85, const Color(0xFFA1F531)),
                      _buildMacroIndicator('Fat', '${(30 - fatEaten).clamp(0, 30)}g left', fatEaten / 30, Colors.redAccent),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Meals Sections
            _buildMealSection(context, 'Breakfast', mealProvider),
            const SizedBox(height: 16),
            _buildMealSection(context, 'Lunch', mealProvider),
            const SizedBox(height: 16),
            _buildMealSection(context, 'Dinner', mealProvider),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(String label, String leftLabel, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(width: 8),
            Text(leftLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearPercentIndicator(
          width: 80.0,
          lineHeight: 4.0,
          percent: percent.clamp(0.0, 1.0),
          backgroundColor: Colors.white24,
          progressColor: color,
          padding: EdgeInsets.zero,
          barRadius: const Radius.circular(2),
        ),
      ],
    );
  }

  Widget _buildMealSection(BuildContext context, String type, MealProvider mealProvider) {
    final meals = mealProvider.getMealsByType(type);
    final totalCalories = meals.fold<int>(0, (sum, meal) => sum + meal.calories);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525), // Lighter dark for cards
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$totalCalories kcal',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddMealScreen(mealType: type)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Color(0xFFA1F531), size: 24),
                ),
              )
            ],
          ),
          if (meals.isNotEmpty) const SizedBox(height: 16),
          ...meals.map((meal) => Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '1 serving', // Mock serving
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                Text(
                  '${meal.calories} kcal',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
