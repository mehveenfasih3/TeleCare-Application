import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:telecare_app/offline/model.dart';
import 'dart:convert';
import '../../utils/colors.dart';
import 'appointment_booking.dart';
import 'video_consultation.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _medicines = [];
  String _healthRecommendation = '';
  bool _isLoadingRecommendations = false;

  @override
  void initState() {
    super.initState();
    _loadMedicines();
    _getHealthRecommendations();
  }

  Future<void> _loadMedicines() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client
          .from('medicines')
          .select()
          .eq('user_id', userId)
          .order('time', ascending: true);

      setState(() {
        _medicines = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading medicines: $e');
    }
  }

  Future<void> _getHealthRecommendations() async {
    setState(() => _isLoadingRecommendations = true);

    try {
      final cerebrasKey = dotenv.env['CEREBRAS_API_KEY'];

      if (cerebrasKey == null || cerebrasKey.isEmpty) {
        throw Exception('Cerebras API key not found in .env');
      }
      final response = await http.post(
        Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cerebrasKey',
        },
        body: jsonEncode({
          'model': 'llama3.1-8b',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful health assistant. Provide brief, practical health tips and wellness advice.',
            },
            {
              'role': 'user',
              'content':
                  'Give me a daily health tip or wellness recommendation in 2-3 sentences.',
            },
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _healthRecommendation = data['choices'][0]['message']['content'];
        });
      }
    } catch (e) {
      setState(() {
        _healthRecommendation =
            'Stay hydrated, eat balanced meals, and maintain regular exercise for optimal health.';
      });
    } finally {
      setState(() => _isLoadingRecommendations = false);
    }
  }

  void _showAddMedicineDialog() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    TimeOfDay? selectedTime;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Medicine'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    selectedTime == null
                        ? 'Select Time'
                        : 'Time: ${selectedTime?.format(context)}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      setDialogState(() => selectedTime = time);
                    }
                  },
                ),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Select Date'
                        : 'Date: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    dosageController.text.isNotEmpty &&
                    selectedTime != null &&
                    selectedDate != null) {
                  await _addMedicine(
                    nameController.text,
                    dosageController.text,
                    selectedTime!,
                    selectedDate!,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryPurple,
              ),
              child: const Text(
                'Add',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMedicine(
    String name,
    String dosage,
    TimeOfDay time,
    DateTime date,
  ) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      await Supabase.instance.client.from('medicines').insert({
        'user_id': userId,
        'name': name,
        'dosage': dosage,
        'time':
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'date': date.toIso8601String(),
      });

      _loadMedicines();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medicine added successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding medicine: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        elevation: 0,
        title: const Text('Home', style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(
          //     Icons.notifications_outlined,
          //     color: AppColors.white,
          //   ),
          //   onPressed: () {},
          // ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadMedicines();
          await _getHealthRecommendations();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              _buildHealthRecommendation(),
              _buildMedicineReminders(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMedicineDialog,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: AppColors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(gradient: AppColors.purpleGradient),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder(
                    future: Supabase.instance.client
                        .from('users')
                        .select()
                        .eq('id', Supabase.instance.client.auth.currentUser!.id)
                        .single(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final user = snapshot.data as Map<String, dynamic>;
                        return Text(
                          '${user['first_name']} ${user['last_name']}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return const Text(
                        'Patient',
                        style: TextStyle(color: AppColors.white, fontSize: 18),
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
            _buildDrawerItem(Icons.calendar_today, 'Book Appointments', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AppointmentBookingScreen(),
                ),
              );
            }),
            _buildDrawerItem(Icons.video_call, 'Current Appointments', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoConsultationScreen(),
                ),
              );
            }),
            // _buildDrawerItem(
            //   Icons.medical_services,
            //   'My Medicines',
            //   () => Navigator.pop(context),
            // ),
            _buildDrawerItem(Icons.person_2, 'Telecare Doctor', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LungCancerPredictionScreen(),
                ),
              );
            }),

            const Divider(),

            _buildDrawerItem(Icons.logout, 'Logout', () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryPurple),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder(
            future: Supabase.instance.client
                .from('users')
                .select()
                .eq('id', Supabase.instance.client.auth.currentUser!.id)
                .single(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final user = snapshot.data as Map<String, dynamic>;
                return Text(
                  'Welcome, ${user['first_name']}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                );
              }
              return const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 16, color: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthRecommendation() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primaryPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daily Health Tip',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingRecommendations
              ? const Center(child: CircularProgressIndicator())
              : Text(
                  _healthRecommendation,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMedicineReminders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medicine Reminders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _showAddMedicineDialog,
                child: const Text(
                  'Add New',
                  style: TextStyle(color: AppColors.primaryPurple),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _medicines.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 60,
                          color: AppColors.lightPurple,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No medicines added yet',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medicines.length,
                  itemBuilder: (context, index) {
                    final medicine = _medicines[index];
                    return _buildMedicineCard(medicine);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.lightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.medication, color: AppColors.primaryPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dosage: ${medicine['dosage']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Time: ${medicine['time']}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: () async {
              await Supabase.instance.client
                  .from('medicines')
                  .delete()
                  .eq('id', medicine['id']);
              _loadMedicines();
            },
          ),
        ],
      ),
    );
  }
}
