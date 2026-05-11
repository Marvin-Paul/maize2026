import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../../providers/scan_provider.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performAnalysis();
    });
  }

  void _performAnalysis() async {
    final scanProvider = Provider.of<ScanProvider>(context, listen: false);
    final success = await scanProvider.analyzeImage();

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Analysis failed. Check your connection.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ScanProvider>(
        builder: (context, scan, _) {
          if (scan.isAnalyzing) {
            return _buildLoadingState();
          } else if (scan.predictionResult != null) {
            return _buildResults(scan.predictionResult!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitRipple(color: Color(0xFF2E7D32), size: 150),
          const SizedBox(height: 40),
          const Text(
            'Initiating Neural Scan',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          const Text(
            'Analyzing leaf patterns and texture...',
            style: TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 40),
          _buildLoadingStep('Extracting features', true),
          _buildLoadingStep('Identifying pathogens', false),
          _buildLoadingStep('Calculating health index', false),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(String text, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
      child: Row(
        children: [
          Icon(
            active ? Icons.check_circle : Icons.radio_button_unchecked,
            color: active ? const Color(0xFF81C784) : Colors.black12,
            size: 20,
          ),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(
              color: active ? Colors.black : Colors.white38,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(Map<String, dynamic> result) {
    final prediction = result['prediction'];
    final disease = prediction['disease'];
    final confidence = (prediction['confidence'] as num).toStringAsFixed(1);
    final healthIndex = (prediction['health_index'] as num).toInt();
    final symptoms = (prediction['symptoms'] as List).cast<String>();
    final recommendations =
        (prediction['recommendations'] as List).cast<String>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Provider.of<ScanProvider>(context, listen: false).imageBytes != null 
              ? Image.memory(
                  Provider.of<ScanProvider>(context, listen: false).imageBytes!,
                  fit: BoxFit.cover,
                )
              : Container(color: Colors.white),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDiagnosisHeader(disease, confidence, healthIndex),
                const SizedBox(height: 30),
                _buildSectionTitle('Symptoms Found'),
                const SizedBox(height: 12),
                ...symptoms.map((s) => _buildBulletItem(s)),
                const SizedBox(height: 30),
                _buildSectionTitle('Treatment Protocol'),
                const SizedBox(height: 12),
                ...recommendations.map((r) =>
                    _buildBulletItem(r, icon: Icons.medical_services_outlined)),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        const Text('New Scan', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisHeader(String disease, String confidence, int health) {
    Color statusColor =
        health > 80 ? Colors.green : (health > 50 ? Colors.orange : Colors.red);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber, size: 14, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      disease.toUpperCase(),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                disease,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$confidence%',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: statusColor),
            ),
            const Text('CONFIDENCE',
                style: TextStyle(color: Colors.black54, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  Widget _buildBulletItem(String text, {IconData icon = Icons.circle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(icon,
                size: icon == Icons.circle ? 8 : 18,
                color: const Color(0xFF81C784)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
