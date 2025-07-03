import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isSignToSpeech = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF6E21B5), // Mor arka plan
      child: Column(
        children: [
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'İşaret → Konuşma',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                child: Switch(
                  value: !isSignToSpeech,
                  onChanged: (val) {
                    setState(() {
                      isSignToSpeech = !val;
                    });
                  },
                  activeColor: const Color(0xFF6E21B5),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Konuşma → İşaret',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 480,
            child: Center(
              child: Container(
                width: 365,
                height: 465,
                decoration: BoxDecoration(
                  color: Color(0xFF232B36),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam, size: 48, color: Colors.white38),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          // Kamera alanı bitti
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF6E21B5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              onPressed: () {
                // Chat bot açma işlemi buraya eklenebilir
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 20, color: Color(0xFF6E21B5)),
                  SizedBox(width: 8),
                  Text(
                    'Chat Bot',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E21B5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
