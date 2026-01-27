import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LungCancerPredictionScreen extends StatefulWidget {
  const LungCancerPredictionScreen({super.key});

  @override
  State<LungCancerPredictionScreen> createState() => _LungCancerPredictionScreenState();
}

class _LungCancerPredictionScreenState extends State<LungCancerPredictionScreen> {
  final ageController = TextEditingController();
  String result = "Fill details and See predictions";
  Color resultColor = const Color.fromARGB(255, 189, 189, 189);
  bool isLoading = false;
  
  int gender = 0;
  int smoking = 0;
  int yellowFingers = 0;
  int anxiety = 0;
  int peerPressure = 0;
  int chronicDisease = 0;
  int fatigue = 0;
  int allergy = 0;
  int wheezing = 0;
  int alcohol = 0;
  int coughing = 0;
  int shortnessOfBreath = 0;
  int swallowingDifficulty = 0;
  int chestPain = 0;

  @override
  void dispose() {
    ageController.dispose();
    super.dispose();
  }

  void predict() {
    if (ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter age'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      final riskScore = calculateRiskScore();
      final riskPercentage = (riskScore * 100).toStringAsFixed(1);
      
      setState(() {
        isLoading = false;
        if (riskScore > 0.5) {
          result = "High Lung Cancer Risk\n$riskPercentage%";
          resultColor = AppColors.error;
        } else {
          result = "Low Lung Cancer Risk\n${(100 - double.parse(riskPercentage)).toStringAsFixed(1)}%";
          resultColor = AppColors.success;
        }
      });
    });
  }

  double calculateRiskScore() {
    int totalRiskFactors = 0;
    int maxRiskFactors = 23;
    
    if (smoking == 1) totalRiskFactors += 3;
    if (yellowFingers == 1) totalRiskFactors += 2;
    if (anxiety == 1) totalRiskFactors += 1;
    if (peerPressure == 1) totalRiskFactors += 1;
    if (chronicDisease == 1) totalRiskFactors += 2;
    if (fatigue == 1) totalRiskFactors += 1;
    if (allergy == 1) totalRiskFactors += 1;
    if (wheezing == 1) totalRiskFactors += 2;
    if (alcohol == 1) totalRiskFactors += 1;
    if (coughing == 1) totalRiskFactors += 2;
    if (shortnessOfBreath == 1) totalRiskFactors += 2;
    if (swallowingDifficulty == 1) totalRiskFactors += 1;
    if (chestPain == 1) totalRiskFactors += 2;
    
    int age = int.tryParse(ageController.text) ?? 0;
    if (age > 50) totalRiskFactors += 2;
    if (age > 60) totalRiskFactors += 1;
    
    return (totalRiskFactors / maxRiskFactors).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.primaryPurple,
        title: const Text(
          'AI Doctor',
          style: TextStyle(color: AppColors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultCard(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAgeInput(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildToggleTile('Male', 'Female', gender, (val) => setState(() => gender = val))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Risk Factors Assessment',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRiskFactorGrid(),
                  const SizedBox(height: 30),
                  _buildPredictButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoading 
              ? [AppColors.info, AppColors.info.withOpacity(0.7)]
              : [resultColor, resultColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: (isLoading ? AppColors.info : resultColor).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            const CircularProgressIndicator(color: AppColors.white)
          else
            Icon(
              resultColor == AppColors.error ? Icons.warning_rounded : Icons.check_circle_rounded,
              size: 70,
              color: AppColors.white,
            ),
          const SizedBox(height: 20),
          Text(
            result,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Analyzing...' : 'Lung Cancer Risk Assessment',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: ageController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'Enter age',
          labelText: 'Age',
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primaryPurple),
          border: InputBorder.none,
        ),
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildToggleTile(String option1, String option2, int selected, Function(int) onChanged) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => onChanged(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selected == 0 ? AppColors.primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    option1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected == 0 ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => onChanged(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selected == 1 ? AppColors.primaryPurple : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    option2,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selected == 1 ? AppColors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskFactorGrid() {
    final factors = [
      {'label': 'Smoking', 'icon': Icons.smoking_rooms, 'value': smoking, 'setter': (val) => setState(() => smoking = val)},
      {'label': 'Yellow Fingers', 'icon': Icons.front_hand, 'value': yellowFingers, 'setter': (val) => setState(() => yellowFingers = val)},
      {'label': 'Anxiety', 'icon': Icons.psychology_outlined, 'value': anxiety, 'setter': (val) => setState(() => anxiety = val)},
      {'label': 'Peer Pressure', 'icon': Icons.group, 'value': peerPressure, 'setter': (val) => setState(() => peerPressure = val)},
      {'label': 'Chronic Disease', 'icon': Icons.medical_services, 'value': chronicDisease, 'setter': (val) => setState(() => chronicDisease = val)},
      {'label': 'Fatigue', 'icon': Icons.battery_alert, 'value': fatigue, 'setter': (val) => setState(() => fatigue = val)},
      {'label': 'Allergy', 'icon': Icons.local_hospital, 'value': allergy, 'setter': (val) => setState(() => allergy = val)},
      {'label': 'Wheezing', 'icon': Icons.air, 'value': wheezing, 'setter': (val) => setState(() => wheezing = val)},
      {'label': 'Alcohol', 'icon': Icons.liquor, 'value': alcohol, 'setter': (val) => setState(() => alcohol = val)},
      {'label': 'Coughing', 'icon': Icons.coronavirus, 'value': coughing, 'setter': (val) => setState(() => coughing = val)},
      {'label': 'Shortness of Breath', 'icon': Icons.air_outlined, 'value': shortnessOfBreath, 'setter': (val) => setState(() => shortnessOfBreath = val)},
      {'label': 'Swallowing Difficulty', 'icon': Icons.restaurant, 'value': swallowingDifficulty, 'setter': (val) => setState(() => swallowingDifficulty = val)},
      {'label': 'Chest Pain', 'icon': Icons.favorite_border, 'value': chestPain, 'setter': (val) => setState(() => chestPain = val)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: factors.length,
      itemBuilder: (context, index) {
        final factor = factors[index];
        return _buildRiskFactorTile(
          factor['label'] as String,
          factor['icon'] as IconData,
          factor['value'] as int,
          factor['setter'] as Function(int),
        );
      },
    );
  }

  Widget _buildRiskFactorTile(String label, IconData icon, int value, Function(int) onChanged) {
    final isYes = value == 1;
    return InkWell(
      onTap: () => onChanged(isYes ? 0 : 1),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isYes ? AppColors.primaryPurple : AppColors.lightGray,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isYes ? AppColors.primaryPurple : AppColors.textSecondary).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (isYes ? AppColors.primaryPurple : AppColors.lightGray).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isYes ? AppColors.primaryPurple : AppColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isYes ? AppColors.primaryPurple : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isYes ? AppColors.primaryPurple : AppColors.lightGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isYes ? 'YES' : 'NO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isYes ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : predict,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          shadowColor: AppColors.primaryPurple.withOpacity(0.4),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, color: AppColors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Calculate Risk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}