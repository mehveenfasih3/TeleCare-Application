import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/colors.dart';
import 'model.dart';

class TelecareInfoHomeScreen extends StatefulWidget {
  const TelecareInfoHomeScreen({super.key});

  @override
  State<TelecareInfoHomeScreen> createState() => _TelecareInfoHomeScreenState();
}

class _TelecareInfoHomeScreenState extends State<TelecareInfoHomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(_rotationController);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.offWhite,
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildContent(),
                ],
              ),
            ),
          ),
        ],
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
              decoration: BoxDecoration(
                gradient: AppColors.purpleGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.health_and_safety,
                      size: 40,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Telecare',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const Text(
                  //   'AI-Powered Healthcare',
                  //   style: TextStyle(
                  //     color: AppColors.white,
                  //     fontSize: 14,
                  //   ),
                  // ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primaryPurple),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.psychology, color: AppColors.primaryPurple),
              title: const Text('AI Doctor'),
              subtitle: const Text('Lung Cancer Risk Assessment'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LungCancerPredictionScreen(),
                  ),
                );
              },
            ),
         
           
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: BackgroundPainter(_rotationAnimation.value),
          child: Container(),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                icon: const Icon(Icons.menu, color: AppColors.primaryPurple, size: 28),
              ),
              const Spacer(),
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(Icons.notifications_outlined, color: AppColors.primaryPurple, size: 28),
              // ),
            ],
          ),
          const SizedBox(height: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryPurple.withOpacity(0.4),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'Telecare',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeTransition(
            opacity: _fadeAnimation,
            child: const Text(
              'Your Health, Our Priority',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFeatureCard(
            'Comprehensive Healthcare',
            'Access to specialized doctors, nurses, and medical professionals for all your health needs',
            Icons.local_hospital,
            AppColors.primaryPurple,
            0,
          ),
          _buildFeatureCard(
            'Video Consultations',
            'Connect with healthcare providers from anywhere through secure video calls',
            Icons.video_call,
            AppColors.info,
            100,
          ),
          _buildFeatureCard(
            'Medicine Reminders',
            'Never miss a dose with smart medication tracking and personalized reminders',
            Icons.medication,
            AppColors.success,
            200,
          ),
          _buildFeatureCard(
            'AI Health Assistant',
            'Get intelligent health recommendations powered by advanced AI technology',
            Icons.psychology,
            AppColors.accentPurple,
            300,
          ),
          _buildFeatureCard(
            'Appointment Management',
            'Easy scheduling and management of all your medical appointments in one place',
            Icons.calendar_today,
            AppColors.warning,
            400,
          ),
          _buildFeatureCard(
            'Emergency Support',
            '24/7 access to emergency contacts and first aid guidance when you need it most',
            Icons.emergency,
            AppColors.error,
            500,
          ),
          const SizedBox(height: 30),
          _buildStatisticsSection(),
          const SizedBox(height: 30),
          _buildMissionSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, int delay) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'By The Numbers',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('10K+', 'Patients'),
              Container(width: 1, height: 50, color: AppColors.white.withOpacity(0.3)),
              _buildStatItem('500+', 'Doctors'),
              Container(width: 1, height: 50, color: AppColors.white.withOpacity(0.3)),
              _buildStatItem('50+', 'Nurses'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: AppColors.primaryPurple,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Our Mission',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Telecare is dedicated to making quality healthcare accessible to everyone, everywhere. We leverage cutting-edge technology to connect patients with healthcare professionals, ensuring timely care and better health outcomes.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Our Values',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildValueItem('Excellence in Care'),
          _buildValueItem('Patient Privacy & Security'),
          _buildValueItem('Innovation in Healthcare'),
          _buildValueItem('Accessibility for All'),
        ],
      ),
    );
  }

  Widget _buildValueItem(String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundPainter extends CustomPainter {
  final double rotation;

  BackgroundPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 3;

    for (int i = 0; i < 3; i++) {
      final radius = 100.0 + (i * 50);
      final opacity = 0.03 - (i * 0.01);
      
      paint.color = AppColors.primaryPurple.withOpacity(opacity);
      
      final offsetX = math.cos(rotation + i) * 30;
      final offsetY = math.sin(rotation + i) * 30;
      
      canvas.drawCircle(
        Offset(centerX + offsetX, centerY + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}