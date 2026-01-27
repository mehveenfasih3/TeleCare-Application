// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/colors.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class DoctorHomeScreen extends StatefulWidget {
//   const DoctorHomeScreen({super.key});

//   @override
//   State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
// }

// class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   List<Map<String, dynamic>> _appointments = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadAppointments();
//   }

//   Future<void> _loadAppointments() async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser!.id;

//       final response = await Supabase.instance.client
//           .from('appointments')
//           .select('*, users!appointments_patient_id_fkey(*), rooms(*)')
//           .eq('doctor_id', userId)
//           .order('date', ascending: true);

//       setState(() {
//         _appointments = List<Map<String, dynamic>>.from(response);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       print('Error loading appointments: $e');
//     }
//   }

//   Future<String?> _createMeetingRoom() async {
//     final apiKey = dotenv.env['DAILY_API_KEY'];

//     try {
//       final response = await http.post(
//         Uri.parse('https://api.daily.co/v1/rooms'),
//         headers: {
//           'Authorization': 'Bearer $apiKey',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           'properties': {
//             'enable_chat': true,
//             'enable_screenshare': true,
//             'start_audio_off': false,
//             'start_video_off': false,
//           },
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return data['url'];
//       }
//     } catch (e) {
//       print('Error creating room: $e');
//     }
//     return null;
//   }

//   Future<void> _updateAppointmentStatus(
//     String appointmentId,
//     String status,
//   ) async {
//     try {
//       await Supabase.instance.client
//           .from('appointments')
//           .update({'status': status})
//           .eq('id', appointmentId);

//       _loadAppointments();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Appointment $status'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error updating appointment: $e'),
//           backgroundColor: AppColors.error,
//         ),
//       );
//     }
//   }

//   Future<void> _createOnlineMeeting(String appointmentId) async {
//     final meetingUrl = await _createMeetingRoom();

//     if (meetingUrl != null) {
//       try {
//         await Supabase.instance.client
//             .from('appointments')
//             .update({'meeting_link': meetingUrl, 'status': 'confirmed'})
//             .eq('id', appointmentId);

//         _loadAppointments();
//         print('Meeting room created: $meetingUrl');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Meeting room created successfully'),
//             backgroundColor: AppColors.success,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error saving meeting link: $e'),
//             backgroundColor: AppColors.error,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: AppColors.offWhite,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryPurple,
//         elevation: 0,
//         title: const Text(
//           'Doctor Dashboard',
//           style: TextStyle(color: AppColors.white),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: AppColors.white),
//           onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.notifications_outlined,
//               color: AppColors.white,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: RefreshIndicator(
//         onRefresh: _loadAppointments,
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _appointments.isEmpty
//             ? Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.calendar_today_outlined,
//                       size: 80,
//                       color: AppColors.lightPurple,
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'No appointments scheduled',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             : ListView.builder(
//                 padding: const EdgeInsets.all(20),
//                 itemCount: _appointments.length,
//                 itemBuilder: (context, index) {
//                   final appointment = _appointments[index];
//                   return _buildAppointmentCard(appointment);
//                 },
//               ),
//       ),
//     );
//   }

//   Widget _buildDrawer() {
//     return Drawer(
//       child: Container(
//         color: AppColors.white,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(gradient: AppColors.purpleGradient),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.end,
//                 children: [
//                   const CircleAvatar(
//                     radius: 35,
//                     backgroundColor: AppColors.white,
//                     child: Icon(
//                       Icons.person,
//                       size: 40,
//                       color: AppColors.primaryPurple,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   FutureBuilder(
//                     future: Supabase.instance.client
//                         .from('users')
//                         .select()
//                         .eq('id', Supabase.instance.client.auth.currentUser!.id)
//                         .single(),
//                     builder: (context, snapshot) {
//                       if (snapshot.hasData) {
//                         final user = snapshot.data as Map<String, dynamic>;
//                         return Text(
//                           'Dr. ${user['first_name']} ${user['last_name']}',
//                           style: const TextStyle(
//                             color: AppColors.white,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         );
//                       }
//                       return const Text(
//                         'Doctor',
//                         style: TextStyle(color: AppColors.white, fontSize: 18),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(
//                 Icons.dashboard,
//                 color: AppColors.primaryPurple,
//               ),
//               title: const Text('Dashboard'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(
//                 Icons.calendar_today,
//                 color: AppColors.primaryPurple,
//               ),
//               title: const Text('Appointments'),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people, color: AppColors.primaryPurple),
//               title: const Text('Patients'),
//               onTap: () {},
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(
//                 Icons.settings,
//                 color: AppColors.primaryPurple,
//               ),
//               title: const Text('Settings'),
//               onTap: () {},
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout, color: AppColors.primaryPurple),
//               title: const Text('Logout'),
//               onTap: () async {
//                 await Supabase.instance.client.auth.signOut();
//                 Navigator.of(context).pushReplacementNamed('/');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
//     final patient = appointment['users'];
//     final room = appointment['rooms'];
//     final isOnsite = appointment['onsite'] ?? false;
//     final status = appointment['status'] ?? 'pending';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryPurple.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: AppColors.purpleGradient,
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: const Icon(
//                   Icons.person,
//                   size: 30,
//                   color: AppColors.white,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${patient['first_name']} ${patient['last_name']}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       patient['email'] ?? '',
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(status).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   status.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                     color: _getStatusColor(status),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Divider(),
//           const SizedBox(height: 16),
//           Text(
//             'Reason: ${appointment['reason'] ?? 'Not specified'}',
//             style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(
//                 Icons.calendar_today,
//                 size: 18,
//                 color: AppColors.primaryPurple,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 appointment['date'] != null
//                     ? DateTime.parse(
//                         appointment['date'],
//                       ).toString().split(' ')[0]
//                     : 'Date not set',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Icon(Icons.access_time, size: 18, color: AppColors.primaryPurple),
//               const SizedBox(width: 8),
//               Text(
//                 appointment['time'] ?? 'Time not set',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Row(
//             children: [
//               Icon(
//                 isOnsite ? Icons.location_on : Icons.video_call,
//                 size: 18,
//                 color: AppColors.primaryPurple,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 isOnsite
//                     ? 'Onsite - ${room != null ? room['name'] : 'Room not assigned'}'
//                     : 'Online Consultation',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           if (isOnsite && room != null) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.lightPurple.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 'Room: ${room['name']}',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryPurple,
//                 ),
//               ),
//             ),
//           ],
//           if (!isOnsite && appointment['meeting_link'] != null) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: AppColors.info.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   const Icon(Icons.link, size: 16, color: AppColors.info),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       appointment['meeting_link'],
//                       style: const TextStyle(
//                         fontSize: 12,
//                         color: AppColors.info,
//                       ),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           if (status == 'pending') ...[
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _updateAppointmentStatus(
//                       appointment['id'],
//                       'confirmed',
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.success,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Accept',
//                       style: TextStyle(color: AppColors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => _updateAppointmentStatus(
//                       appointment['id'],
//                       'cancelled',
//                     ),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: AppColors.error),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       'Decline',
//                       style: TextStyle(color: AppColors.error),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           if (!isOnsite &&
//               status == 'confirmed' &&
//               appointment['meeting_link'] == null) ...[
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _createOnlineMeeting(appointment['id']),
//                 icon: const Icon(Icons.video_call, color: AppColors.white),
//                 label: const Text(
//                   'Create Meeting Room',
//                   style: TextStyle(color: AppColors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryPurple,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'confirmed':
//         return AppColors.success;
//       case 'pending':
//         return AppColors.warning;
//       case 'completed':
//         return AppColors.info;
//       case 'cancelled':
//         return AppColors.error;
//       default:
//         return AppColors.textSecondary;
//     }
//   }
// }




import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/colors.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final response = await Supabase.instance.client
          .from('appointments')
          .select('*, users!appointments_patient_id_fkey(*), rooms(*)')
          .eq('doctor_id', userId)
          .order('date', ascending: true);

      setState(() {
        _appointments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading appointments: $e');
    }
  }

  Future<String?> _createMeetingRoom() async {
    try {
      // Generate unique room name using timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final roomName = 'healthcare_appointment_$timestamp';
      
      // Using Jitsi Meet - completely free, no API key needed!
      final meetingUrl = 'https://meet.jit.si/$roomName';
      
      print('Jitsi room created: $meetingUrl');
      return meetingUrl;
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  Future<void> _updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await Supabase.instance.client
          .from('appointments')
          .update({'status': status})
          .eq('id', appointmentId);

      _loadAppointments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment $status'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating appointment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _createOnlineMeeting(String appointmentId) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final meetingUrl = await _createMeetingRoom();

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (meetingUrl != null) {
      try {
        await Supabase.instance.client
            .from('appointments')
            .update({
              'meeting_link': 'https:$meetingUrl',
              'status': 'confirmed'
            })
            .eq('id', appointmentId);

        _loadAppointments();
        
        if (mounted) {
          // Show success dialog with meeting link
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Meeting Created!',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your video consultation room is ready.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lightPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.link,
                          size: 20,
                          color: AppColors.primaryPurple,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meetingUrl,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryPurple,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Patient can now join the consultation',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving meeting link: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create meeting room'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
        title: const Text(
          'Doctor Dashboard',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: _isLoading
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
                      'No appointments scheduled',
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
                          'Dr. ${user['first_name']} ${user['last_name']}',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return const Text(
                        'Doctor',
                        style: TextStyle(color: AppColors.white, fontSize: 18),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.dashboard,
                color: AppColors.primaryPurple,
              ),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.calendar_today,
                color: AppColors.primaryPurple,
              ),
              title: const Text('Appointments'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primaryPurple),
              title: const Text('Patients'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.settings,
                color: AppColors.primaryPurple,
              ),
              title: const Text('Settings'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.primaryPurple),
              title: const Text('Logout'),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final patient = appointment['users'];
    final room = appointment['rooms'];
    final isOnsite = appointment['onsite'] ?? false;
    final status = appointment['status'] ?? 'pending';

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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.person,
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
                      '${patient['first_name']} ${patient['last_name']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      patient['email'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Reason: ${appointment['reason'] ?? 'Not specified'}',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
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
                    ? DateTime.parse(
                        appointment['date'],
                      ).toString().split(' ')[0]
                    : 'Date not set',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.access_time, size: 18, color: AppColors.primaryPurple),
              const SizedBox(width: 8),
              Text(
                appointment['time'] ?? 'Time not set',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isOnsite ? Icons.location_on : Icons.video_call,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                isOnsite
                    ? 'Onsite - ${room != null ? room['name'] : 'Room not assigned'}'
                    : 'Online Consultation',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (isOnsite && room != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Room: ${room['name']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
          if (!isOnsite && appointment['meeting_link'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: AppColors.info),
                      const SizedBox(width: 8),
                      const Text(
                        'Meeting Link:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appointment['meeting_link'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.info,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateAppointmentStatus(
                      appointment['id'],
                      'confirmed',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateAppointmentStatus(
                      appointment['id'],
                      'cancelled',
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (!isOnsite &&
              status == 'confirmed' &&
              appointment['meeting_link'] == null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _createOnlineMeeting(appointment['id']),
                icon: const Icon(Icons.video_call, color: AppColors.white),
                label: const Text(
                  'Create Meeting Room',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.info;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}