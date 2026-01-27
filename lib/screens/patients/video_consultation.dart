// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../utils/colors.dart';

// class VideoConsultationScreen extends StatefulWidget {
//   const VideoConsultationScreen({super.key});

//   @override
//   State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
// }

// class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
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
//           .select('*, users!appointments_doctor_id_fkey(*), rooms(*)')
//           .eq('patient_id', userId)
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

//   void _showJoinMeetingDialog(Map<String, dynamic> appointment) {
//     final nameController = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Join Video Consultation'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(
//                 labelText: 'Your Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Meeting Link: ${appointment['meeting_link'] ?? 'Not available'}',
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primaryPurple,
//             ),
//             child: const Text('Join', style: TextStyle(color: AppColors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.offWhite,
//       appBar: AppBar(
//         backgroundColor: AppColors.primaryPurple,
//         title: const Text('Current Appointments', style: TextStyle(color: AppColors.white)),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: AppColors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _appointments.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(
//                         Icons.video_call_outlined,
//                         size: 80,
//                         color: AppColors.lightPurple,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'No appointments scheduled',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadAppointments,
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(20),
//                     itemCount: _appointments.length,
//                     itemBuilder: (context, index) {
//                       final appointment = _appointments[index];
//                       return _buildAppointmentCard(appointment);
//                     },
//                   ),
//                 ),
//     );
//   }

//   Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
//     final doctor = appointment['users'];
//     final room = appointment['rooms'];
//     final isOnsite = appointment['onsite'] ?? false;
    
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
//                       'Dr. ${doctor['first_name']} ${doctor['last_name']}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       appointment['reason'] ?? '',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           const Divider(),
//           const SizedBox(height: 16),
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
//                     ? DateTime.parse(appointment['date']).toString().split(' ')[0]
//                     : 'Date not set',
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Icon(
//                 Icons.access_time,
//                 size: 18,
//                 color: AppColors.primaryPurple,
//               ),
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
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.meeting_room,
//                     size: 20,
//                     color: AppColors.primaryPurple,
//                   ),
//                   const SizedBox(width: 8),
//                   Text(
//                     'Room: ${room['name']}',
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.primaryPurple,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           if (!isOnsite) ...[
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _showJoinMeetingDialog(appointment),
//                 icon: const Icon(Icons.video_call, color: AppColors.white),
//                 label: const Text(
//                   'Join Video Call',
//                   style: TextStyle(color: AppColors.white),
//                 ),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryPurple,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _getStatusColor(appointment['status']).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               (appointment['status'] ?? 'pending').toUpperCase(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: _getStatusColor(appointment['status']),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String? status) {
//     switch (status?.toLowerCase()) {
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
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
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
          .select('*, users!appointments_doctor_id_fkey(*), rooms(*)')
          .eq('patient_id', userId)
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

  void _showJoinMeetingDialog(Map<String, dynamic> appointment) {
    final meetingLink = appointment['meeting_link'];
    
    if (meetingLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meeting link not available yet. Please wait for doctor to create it.'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    
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
                Icons.video_call,
                color: AppColors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Join Video Consultation',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.videocam,
                    size: 64,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ready to join your video consultation?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Meeting will open in your browser',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Make sure you have a stable internet connection',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _joinVideoCall(meetingLink);
            },
            icon: const Icon(Icons.video_call, color: AppColors.white),
            label: const Text(
              'Join Now',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinVideoCall(String meetingLink) async {
    try {
      final Uri url = Uri.parse(meetingLink);
      
      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening video consultation...'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw 'Could not launch meeting';
      }
    } catch (e) {
      print('Error launching meeting: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open meeting link. Please try again.'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        title: const Text('Current Appointments', style: TextStyle(color: AppColors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_call_outlined,
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
              : RefreshIndicator(
                  onRefresh: _loadAppointments,
                  child: ListView.builder(
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

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final doctor = appointment['users'];
    final room = appointment['rooms'];
    final isOnsite = appointment['onsite'] ?? false;
    final status = appointment['status'] ?? 'pending';
    final meetingLink = appointment['meeting_link'];
    
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
                      'Dr. ${doctor['first_name']} ${doctor['last_name']}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment['reason'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
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
              child: Row(
                children: [
                  Icon(
                    Icons.meeting_room,
                    size: 20,
                    color: AppColors.primaryPurple,
                  ),
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
          ],
          if (!isOnsite) ...[
            const SizedBox(height: 16),
            if (meetingLink != null && status == 'confirmed') ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 20,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Meeting room is ready',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showJoinMeetingDialog(appointment),
                  icon: const Icon(Icons.video_call, color: AppColors.white),
                  label: const Text(
                    'Join Video Call',
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
            ] else if (status == 'confirmed') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_empty,
                      size: 20,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Waiting for doctor to create meeting room',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Appointment pending confirmation',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getStatusColor(status),
              ),
            ),
          ),
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