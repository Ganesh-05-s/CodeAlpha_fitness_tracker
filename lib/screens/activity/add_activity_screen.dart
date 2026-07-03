import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/activity_provider.dart';
import '../../theme/app_theme.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedActivity = 'Running';
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  bool _isCalorieManuallyEdited = false;

  final List<String> _activitiesList = [
    'Running',
    'Walking',
    'Cycling',
    'Gym',
    'Yoga',
    'Swimming',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    // Default duration is 30 mins
    _durationController.text = '30';
    _updateEstimatedCalories();
    
    _durationController.addListener(() {
      if (!_isCalorieManuallyEdited) {
        _updateEstimatedCalories();
      }
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  // Multiplier calories per minute
  int _getCalorieMultiplier(String activity) {
    switch (activity) {
      case 'Running':
        return 12;
      case 'Cycling':
        return 10;
      case 'Swimming':
        return 9;
      case 'Gym':
        return 8;
      case 'Walking':
        return 5;
      case 'Yoga':
        return 4;
      default:
        return 6;
    }
  }

  void _updateEstimatedCalories() {
    final durationText = _durationController.text;
    if (durationText.isNotEmpty) {
      final duration = int.tryParse(durationText) ?? 0;
      final multiplier = _getCalorieMultiplier(_selectedActivity);
      _caloriesController.text = '${duration * multiplier}';
    } else {
      _caloriesController.text = '0';
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _selectedDate.isBefore(today) ? today : _selectedDate;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryPurple,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ActivityProvider>(context, listen: false);
      
      final finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final duration = int.parse(_durationController.text);
      final calories = int.parse(_caloriesController.text);

      provider.addActivity(
        type: _selectedActivity,
        duration: duration,
        calories: calories,
        dateTime: finalDateTime,
      );

      // If logging a walking or running activity, automatically credit user with mock steps
      if (_selectedActivity == 'Walking') {
        // Assume 120 steps per minute
        provider.addSteps(duration * 120);
      } else if (_selectedActivity == 'Running') {
        // Assume 160 steps per minute
        provider.addSteps(duration * 160);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved workout: $_selectedActivity! 🚀'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM dd, yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top header card with illustration or icon
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.directions_run_rounded,
                        size: 44,
                        color: AppTheme.primaryPurple,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Keep it Up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Log your physical activities to keep your goals on track.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Dropdown for Activity Type
                DropdownButtonFormField<String>(
                  value: _selectedActivity,
                  decoration: const InputDecoration(
                    labelText: 'Activity Type',
                    prefixIcon: Icon(Icons.sports_baseball_outlined),
                  ),
                  items: _activitiesList.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedActivity = newValue!;
                      if (!_isCalorieManuallyEdited) {
                        _updateEstimatedCalories();
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Duration Row (Mins)
                TextFormField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (Minutes)',
                    prefixIcon: Icon(Icons.timer_outlined),
                    suffixText: 'mins',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter workout duration';
                    }
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Calories Burned
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories Burned (kcal)',
                    prefixIcon: Icon(Icons.local_fire_department_outlined),
                    suffixText: 'kcal',
                  ),
                  onChanged: (value) {
                    _isCalorieManuallyEdited = true;
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter calories burned';
                    }
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0) {
                      return 'Please enter a valid non-negative number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Date & Time Picker buttons
                Row(
                  children: [
                    // Date
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_outlined, size: 18, color: AppTheme.primaryPurple),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Time
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Time',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_outlined, size: 18, color: AppTheme.primaryPurple),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      timeStr,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Save Workout Button
                ElevatedButton(
                  onPressed: _saveActivity,
                  child: const Text('Save Workout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
