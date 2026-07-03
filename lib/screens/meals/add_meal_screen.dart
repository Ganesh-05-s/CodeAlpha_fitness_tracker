import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/meal_provider.dart';
import '../../theme/app_theme.dart';

class AddMealScreen extends StatefulWidget {
  final String mealType;

  const AddMealScreen({super.key, required this.mealType});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isScanning = false;

  Future<void> _scanFood() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _isScanning = true;
      });

      // Simulate API analysis delay
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _isScanning = false;
        // Mock data from scan
        _nameController.text = 'Grilled Chicken Salad';
        _caloriesController.text = '450';
        _carbsController.text = '15';
        _proteinController.text = '40';
        _fatController.text = '25';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food recognized successfully!')),
      );
    }
  }

  void _saveMeal() {
    if (_formKey.currentState!.validate()) {
      Provider.of<MealProvider>(context, listen: false).addMeal(
        name: _nameController.text.trim(),
        calories: int.tryParse(_caloriesController.text) ?? 0,
        carbs: int.tryParse(_carbsController.text) ?? 0,
        protein: int.tryParse(_proteinController.text) ?? 0,
        fat: int.tryParse(_fatController.text) ?? 0,
        type: widget.mealType,
        dateTime: DateTime.now(),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.mealType}'),
      ),
      body: _isScanning 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.primaryGreen),
                SizedBox(height: 16),
                Text('Analyzing food...', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _scanFood,
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Scan with Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('OR ENTER MANUALLY', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Food Name'),
                    validator: (v) => v!.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                    validator: (v) => v!.isEmpty ? 'Enter calories' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Carbs (g)'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Protein (g)'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Fat (g)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveMeal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save Meal'),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
