import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../scan/scan_screen.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F7FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: AnimationLimiter(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  _buildWeatherCard(),
                  const SizedBox(height: 24),
                  _buildScanActionCard(context),
                  const SizedBox(height: 30),
                  _buildSectionTitle('Recent Activity'),
                  const SizedBox(height: 16),
                  _buildRecentScanItem('Maize Streak Virus', '2 hours ago',
                      '94.5%', Colors.orange),
                  _buildRecentScanItem(
                      'Healthy Leaf', 'Yesterday', '99.2%', Colors.green),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        },
        backgroundColor: const Color(0xFF2E7D32),
        icon: const Icon(Icons.chat_bubble_outline),
        label: const Text('AI Expert'),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning,';
    } else if (hour < 17) {
      return 'Good afternoon,';
    } else {
      return 'Good evening,';
    }
  }

  Widget _buildHeader(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final username = auth.username ?? 'Farmer';
    final displayName = username.isNotEmpty 
        ? 'Farmer ${username[0].toUpperCase()}${username.substring(1)}' 
        : 'Farmer';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getGreeting(),
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () =>
              Provider.of<AuthProvider>(context, listen: false).logout(),
          icon: const Icon(Icons.logout, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Weather',
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '24°C',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Partly Cloudy',
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ],
          ),
          Icon(Icons.wb_cloudy_outlined, size: 60, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildScanActionCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScanScreen()),
        );
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: NetworkImage(
                'https://picsum.photos/seed/maize/400/200'),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
          color: Colors.white,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.camera_alt, size: 32, color: Colors.black),
              ),
              const SizedBox(height: 12),
              const Text(
                'Identify Disease',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Snap a photo of your maize leaf',
                style: TextStyle(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child:
              const Text('See All', style: TextStyle(color: Color(0xFF81C784))),
        ),
      ],
    );
  }

  Widget _buildRecentScanItem(
      String disease, String time, String confidence, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.coronavirus_outlined, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(time,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                confidence,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text('Confidence',
                  style: TextStyle(color: Colors.black54, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
