import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/colors.dart';

class NurseHome extends StatefulWidget {
  const NurseHome({super.key});

  @override
  State<NurseHome> createState() => _NurseHomeEnhancedState();
}

class _NurseHomeEnhancedState extends State<NurseHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _beds = [];
  List<Map<String, dynamic>> _emergencyPatients = [];
  bool _isLoadingAppointments = true;
  bool _isLoadingRooms = true;
  bool _isLoadingBeds = true;
  bool _isLoadingEmergency = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadRooms();
    _loadBeds();
    _loadEmergencyPatients();
  }

  Future<void> _loadEmergencyPatients() async {
    try {
      final response = await Supabase.instance.client
          .from('emergency_patients')
          .select('*, rooms(*), beds(*)')
          .order('created_at', ascending: false);

      setState(() {
        _emergencyPatients = List<Map<String, dynamic>>.from(response);
        _isLoadingEmergency = false;
      });
    } catch (e) {
      setState(() => _isLoadingEmergency = false);
      print('Error loading emergency patients: $e');
    }
  }

Future<void> _loadAppointments() async {
  setState(() => _isLoadingAppointments = true);
  
  try {
    // Simple query first to test RLS
    final response = await Supabase.instance.client
        .from('appointments')
        .select('*')
        .eq('status', 'pending')
        .order('date', ascending: true);

    print('✅ Raw response: $response');
    
    if (mounted) {
      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoadingAppointments = false;
      });
      
      print('✅ Successfully loaded ${_appointments.length} appointments');
    }
  } catch (e) {
    print('❌ Error loading appointments: $e');
    
    if (mounted) {
      setState(() => _isLoadingAppointments = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
 
  Future<void> _loadRooms() async {
    try {
      final response = await Supabase.instance.client
          .from('rooms')
          .select()
          .order('name', ascending: true);

      setState(() {
        _rooms = List<Map<String, dynamic>>.from(response);
        _isLoadingRooms = false;
      });
    } catch (e) {
      setState(() => _isLoadingRooms = false);
      print('Error loading rooms: $e');
    }
  }

  Future<void> _loadBeds() async {
    try {
      final response = await Supabase.instance.client
          .from('beds')
          .select('*, rooms(*), users(*)')
          .order('room_id', ascending: true);

      setState(() {
        _beds = List<Map<String, dynamic>>.from(response);
        _isLoadingBeds = false;
      });
    } catch (e) {
      setState(() => _isLoadingBeds = false);
      print('Error loading beds: $e');
    }
  }

  Future<void> _assignRoom(String appointmentId, String roomId) async {
    try {
      await Supabase.instance.client
          .from('appointments')
          .update({'room_id': roomId})
          .eq('id', appointmentId);

      _loadAppointments();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room assigned successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning room: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _assignEmergencyBed(String patientId, String bedId, String roomId) async {
    try {
      await Supabase.instance.client
          .from('emergency_patients')
          .update({
            'bed_id': bedId,
            'room_id': roomId,
            'status': 'admitted',
          })
          .eq('id', patientId);

      await Supabase.instance.client
          .from('beds')
          .update({'available': false})
          .eq('id', bedId);

      _loadEmergencyPatients();
      _loadBeds();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bed assigned successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning bed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAssignRoomDialog(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _rooms.where((room) => room['available'] == true).map((room) {
            return ListTile(
              title: Text(room['name']),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                _assignRoom(appointment['id'], room['id']);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAssignBedDialog(Map<String, dynamic> patient) {
    final availableBeds = _beds.where((bed) => bed['available'] == true).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Bed'),
        content: SizedBox(
          width: double.maxFinite,
          child: availableBeds.isEmpty
              ? const Center(child: Text('No available beds'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableBeds.length,
                  itemBuilder: (context, index) {
                    final bed = availableBeds[index];
                    final room = bed['rooms'];
                    return ListTile(
                      title: Text('Bed ${bed['bed_number']}'),
                      subtitle: Text('Room: ${room != null ? room['name'] : 'Unknown'}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pop(context);
                        _assignEmergencyBed(patient['id'], bed['id'], bed['room_id']);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomDialog() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Room'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Room Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _createRoom(nameController.text);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
            ),
            child: const Text('Create', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateBedDialog() {
    final bedNumberController = TextEditingController();
    String? selectedRoomId;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Create New Bed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedRoomId,
                  decoration: const InputDecoration(
                    labelText: 'Select Room',
                    border: OutlineInputBorder(),
                  ),
                  items: _rooms.map((room) {
                    return DropdownMenuItem<String>(
                      value: room['id'],
                      child: Text(room['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedRoomId = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bedNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bed Number',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (bedNumberController.text.isNotEmpty && selectedRoomId != null) {
                    await _createBed(selectedRoomId!, bedNumberController.text);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                ),
                child: const Text('Create', style: TextStyle(color: AppColors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _createRoom(String name) async {
    try {
      await Supabase.instance.client.from('rooms').insert({
        'name': name,
        'available': true,
      });

      _loadRooms();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating room: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _createBed(String roomId, String bedNumber) async {
    try {
      await Supabase.instance.client.from('beds').insert({
        'room_id': roomId,
        'bed_number': bedNumber,
        'available': true,
      });

      _loadBeds();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bed created successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating bed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleRoomAvailability(String roomId, bool currentStatus) async {
    try {
      await Supabase.instance.client
          .from('rooms')
          .update({'available': !currentStatus})
          .eq('id', roomId);

      _loadRooms();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Room status updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating room: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleBedAvailability(String bedId, bool currentStatus) async {
    try {
      await Supabase.instance.client
          .from('beds')
          .update({'available': !currentStatus})
          .eq('id', bedId);

      _loadBeds();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bed status updated'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bed: $e'),
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
        title: Text(
          _selectedIndex == 0 ? 'Appointments' : _selectedIndex == 1 ? 'Emergency' : _selectedIndex == 2 ? 'Rooms' : 'Beds',
          style: const TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications_outlined, color: AppColors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildAppointmentsTab(),
          _buildEmergencyTab(),
          _buildRoomsTab(),
          _buildBedsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppColors.primaryPurple,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bed),
            label: 'Beds',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? FloatingActionButton(
              onPressed: _showCreateRoomDialog,
              backgroundColor: AppColors.primaryPurple,
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : _selectedIndex == 3
              ? FloatingActionButton(
                  onPressed: _showCreateBedDialog,
                  backgroundColor: AppColors.primaryPurple,
                  child: const Icon(Icons.add, color: AppColors.white),
                )
              : null,
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
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: AppColors.white,
                    child: Icon(Icons.person, size: 40, color: AppColors.primaryPurple),
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
                        'Nurse',
                        style: TextStyle(color: AppColors.white, fontSize: 18),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard, color: AppColors.primaryPurple),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: AppColors.primaryPurple),
              title: const Text('Appointments'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emergency, color: AppColors.error),
              title: const Text('Emergency'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room, color: AppColors.primaryPurple),
              title: const Text('Room Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bed, color: AppColors.primaryPurple),
              title: const Text('Bed Management'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              },
            ),
            const Divider(),
            // ListTile(
            //   leading: const Icon(Icons.settings, color: AppColors.primaryPurple),
            //   title: const Text('Settings'),
            //   onTap: () {},
            // ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primaryPurple),
              title: const Text('Logout'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: _isLoadingAppointments
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 80,
                        color: AppColors.lightPurple,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No confirmed appointments',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = _appointments[index];
                    return _buildAppointmentCard(appointment);
                  },
                ),
    );
  }

  Widget _buildEmergencyTab() {
    return RefreshIndicator(
      onRefresh: _loadEmergencyPatients,
      child: _isLoadingEmergency
          ? const Center(child: CircularProgressIndicator())
          : _emergencyPatients.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emergency_outlined,
                        size: 80,
                        color: AppColors.error.withOpacity(0.5),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No emergency patients',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _emergencyPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _emergencyPatients[index];
                    return _buildEmergencyCard(patient);
                  },
                ),
    );
  }

  Widget _buildRoomsTab() {
    return RefreshIndicator(
      onRefresh: _loadRooms,
      child: _isLoadingRooms
          ? const Center(child: CircularProgressIndicator())
          : _rooms.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 80,
                        color: AppColors.lightPurple,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No rooms available',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _showCreateRoomDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                        ),
                        child: const Text('Create Room', style: TextStyle(color: AppColors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    return _buildRoomCard(room);
                  },
                ),
    );
  }

  Widget _buildBedsTab() {
    return RefreshIndicator(
      onRefresh: _loadBeds,
      child: _isLoadingBeds
          ? const Center(child: CircularProgressIndicator())
          : _beds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bed_outlined,
                        size: 80,
                        color: AppColors.lightPurple,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No beds available',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _showCreateBedDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                        ),
                        child: const Text('Create Bed', style: TextStyle(color: AppColors.white)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _beds.length,
                  itemBuilder: (context, index) {
                    final bed = _beds[index];
                    return _buildBedCard(bed);
                  },
                ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final room = appointment['rooms'];
    final hasRoom = room != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Patient Information',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Patient ID: ${appointment['patient_id']?.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: hasRoom ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  hasRoom ? 'ASSIGNED' : 'PENDING',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: hasRoom ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                appointment['date'] != null
                    ? DateTime.parse(appointment['date']).toString().split(' ')[0]
                    : 'Date not set',
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 20),
              Icon(
                Icons.access_time,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                appointment['time'] ?? 'Time not set',
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
          if (hasRoom) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.meeting_room, size: 20, color: AppColors.primaryPurple),
                  const SizedBox(width: 8),
                  Text(
                    'Room: ${room['name']}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (appointment['onsite'] == true) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAssignRoomDialog(appointment),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Assign Room', style: TextStyle(color: AppColors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyCard(Map<String, dynamic> patient) {
    final severity = patient['severity'] ?? 'Medium';
    final status = patient['status'] ?? 'waiting';
    final hasBed = patient['beds'] != null;
    
    Color severityColor;
    switch (severity) {
      case 'Critical':
        severityColor = Colors.red;
        break;
      case 'High':
        severityColor = Colors.orange;
        break;
      case 'Medium':
        severityColor = Colors.yellow;
        break;
      default:
        severityColor = Colors.green;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: severityColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: severityColor.withOpacity(0.2),
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emergency, color: severityColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${patient['first_name']} ${patient['last_name']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Age: ${patient['age']} | ${patient['gender']}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: severityColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.description, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  patient['chief_complaint'] ?? 'No complaint',
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          if (hasBed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bed, size: 20, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'Bed: ${patient['beds']['bed_number']} | Room: ${patient['rooms']?['name'] ?? 'Unknown'}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ] else if (status == 'waiting') ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showAssignBedDialog(patient),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Assign Bed', style: TextStyle(color: AppColors.white)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final isAvailable = room['available'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.meeting_room,
              size: 30,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? 'Available' : 'Occupied',
                      style: TextStyle(
                        fontSize: 14,
                        color: isAvailable ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: (value) => _toggleRoomAvailability(room['id'], isAvailable),
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildBedCard(Map<String, dynamic> bed) {
    final isAvailable = bed['available'] ?? false;
    final room = bed['rooms'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.bed,
              size: 30,
              color: isAvailable ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bed ${bed['bed_number']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Room: ${room != null ? room['name'] : 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isAvailable ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAvailable ? 'Available' : 'Occupied',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: (value) => _toggleBedAvailability(bed['id'], isAvailable),
            activeColor: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}