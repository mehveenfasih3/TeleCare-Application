import 'package:flutter/material.dart';
import 'package:telecare_app/screens/patients/emergency_patients.dart';
import '../utils/colors.dart';
import 'auth/signin.dart';
import 'offline/telecare_info.dart';

class IndexScreen extends StatelessWidget {
  const IndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.white, AppColors.offWhite],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryPurple.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    size: 70,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Welcome to Telecare',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Healthcare at your fingertips',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                _buildOptionCard(
                  context,
                  title: 'Continue as User',
                  subtitle: 'Sign in to access your account',
                  icon: Icons.person,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  context,
                  title: 'Emergency Support',
                  subtitle: 'Quick access without signing in',
                  icon: Icons.emergency,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EmergencyRegistrationScreen()),
                    );
                  },
                  isSecondary: true,
                ),
                const SizedBox(height: 16),
                _buildOptionCard(
                  context,
                  title: 'Offline Support',
                  subtitle: 'Access Telecare information',
                  icon: Icons.info_outline,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TelecareInfoHomeScreen()),
                    );
                  },
                  isSecondary: true,
                ),
                const SizedBox(height: 30),
                Text(
                  'By continuing, you agree to our Terms & Privacy Policy',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSecondary ? null : AppColors.purpleGradient,
          color: isSecondary ? AppColors.white : null,
          borderRadius: BorderRadius.circular(20),
          border: isSecondary ? Border.all(color: AppColors.primaryPurple, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: isSecondary
                  ? AppColors.primaryPurple.withOpacity(0.1)
                  : AppColors.primaryPurple.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSecondary ? AppColors.primaryPurple : AppColors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSecondary ? AppColors.white : AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSecondary ? AppColors.textPrimary : AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSecondary ? AppColors.textSecondary : AppColors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              color: isSecondary ? AppColors.primaryPurple : AppColors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}