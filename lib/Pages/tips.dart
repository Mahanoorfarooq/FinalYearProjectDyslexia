import 'package:flutter/material.dart';

class DyslexiaTipsPage extends StatelessWidget {
  const DyslexiaTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'title': 'Use Audiobooks',
        'summary':
            'Audiobooks help individuals absorb content without reading.',
        'detail':
            'Audiobooks allow dyslexic individuals to consume information without struggling through reading. Pairing audio with print can help build word recognition and comprehension.',
        'date': '12 Jun 2025',
      },
      {
        'title': 'Multisensory Learning',
        'summary': 'Engage touch, sound, and visuals for deeper learning.',
        'detail':
            'Using multiple senses when teaching—like tracing letters in sand or using apps that speak words—helps reinforce learning and memory for dyslexic individuals.',
        'date': '12 Jun 2025',
      },
      {
        'title': 'Highlight Keywords',
        'summary': 'Visual cues help focus and retain key information.',
        'detail':
            'Teach learners to highlight or underline important words and ideas. This improves reading comprehension by drawing attention to critical concepts.',
        'date': '12 Jun 2025',
      },
      {
        'title': 'Use Friendly Fonts',
        'summary': 'Use fonts like OpenDyslexic with good spacing.',
        'detail':
            'Fonts specifically designed for dyslexia improve readability. Combine this with clear spacing and a clean layout to reduce reading fatigue.',
        'date': '12 Jun 2025',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tips & Tricks for Dyslexia',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return _buildTipCard(context, tip);
        },
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, Map<String, String> tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip['title']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2C3A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tip['summary']!,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tip['date']!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TipDetailPage(
                        title: tip['title']!,
                        detail: tip['detail']!,
                      ),
                    ),
                  );
                },
                child: const Row(
                  children: [
                    Text(
                      'Read more',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TipDetailPage extends StatelessWidget {
  final String title;
  final String detail;

  const TipDetailPage({
    super.key,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          detail,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
