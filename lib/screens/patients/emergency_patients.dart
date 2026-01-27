import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/colors.dart';

class EmergencyRegistrationScreen extends StatefulWidget {
  const EmergencyRegistrationScreen({super.key});

  @override
  State<EmergencyRegistrationScreen> createState() => _EmergencyRegistrationScreenState();
}

class _EmergencyRegistrationScreenState extends State<EmergencyRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _complaintController = TextEditingController();
  
  String _gender = 'Male';
  String _severity = 'Medium';
  String? _selectedRoomId;
  
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    _emergencyContactPhoneController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    try {
      final response = await Supabase.instance.client
          .from('rooms')
          .select()
          .eq('available', true)
          .order('name', ascending: true);
      
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      print('Error loading rooms: $e');
    }
  }

  Future<void> _submitEmergency() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a preferred room'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final emergencyData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'age': int.parse(_ageController.text.trim()),
        'gender': _gender,
        'phone': _phoneController.text.trim(),
        'emergency_contact': _emergencyContactController.text.trim(),
        'emergency_contact_phone': _emergencyContactPhoneController.text.trim(),
        'chief_complaint': _complaintController.text.trim(),
        'severity': _severity,
        'room_id': _selectedRoomId,
        'status': 'waiting',
      };

      await Supabase.instance.client
          .from('emergency_patients')
          .insert(emergencyData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Emergency registration successful! Please wait for nurse assignment.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.error,
        title: const Row(
          children: [
            Icon(Icons.emergency, color: AppColors.white),
            SizedBox(width: 12),
            Text('Emergency Registration', style: TextStyle(color: AppColors.white)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.error, AppColors.error.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.white, size: 40),
                    SizedBox(height: 12),
                    Text(
                      'Quick Emergency Registration',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fill this form quickly. A nurse will assist you shortly.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildInputCard(
                'First Name',
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter first name',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              
              _buildInputCard(
                'Last Name',
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter last name',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInputCard(
                      'Age',
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Age',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildDropdownCard(
                      'Gender',
                      DropdownButtonFormField<String>(
                        value: _gender,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        items: ['Male', 'Female', 'Other'].map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _gender = value!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              
              _buildInputCard(
                'Phone Number',
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Enter phone number',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Emergency Contact',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildInputCard(
                'Contact Name',
                TextFormField(
                  controller: _emergencyContactController,
                  decoration: const InputDecoration(
                    hintText: 'Emergency contact name',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              
              _buildInputCard(
                'Contact Phone',
                TextFormField(
                  controller: _emergencyContactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Emergency contact phone',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Medical Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildInputCard(
                'Chief Complaint / Symptoms',
                TextFormField(
                  controller: _complaintController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe the medical emergency...',
                    border: InputBorder.none,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please describe the emergency';
                    }
                    return null;
                  },
                ),
              ),
              
              _buildDropdownCard(
                'Severity Level',
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _severity,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'Critical',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.red, size: 12),
                              SizedBox(width: 8),
                              Text('Critical - Life threatening'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'High',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.orange, size: 12),
                              SizedBox(width: 8),
                              Text('High - Urgent'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'Medium',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.yellow, size: 12),
                              SizedBox(width: 8),
                              Text('Medium - Moderate'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'Low',
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              SizedBox(width: 8),
                              Text('Low - Non-urgent'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() => _severity = value!);
                      },
                    ),
                  ],
                ),
              ),
              
              _buildDropdownCard(
                'Preferred Room',
                DropdownButtonFormField<String>(
                  value: _selectedRoomId,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Select preferred room',
                  ),
                  items: _rooms.map((room) {
                    return DropdownMenuItem<String>(
                      value: room['id'],
                      child: Text(room['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRoomId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a room';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, color: AppColors.white),
                            SizedBox(width: 12),
                            Text(
                              'Submit Emergency',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
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

  Widget _buildInputCard(String label, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _buildDropdownCard(String label, Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          child,
        ],
      ),
    );
  }
}