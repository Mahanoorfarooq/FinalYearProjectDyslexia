import 'package:flutter/material.dart';

class IdentifyDyslexiaPage extends StatelessWidget {
  const IdentifyDyslexiaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Identify Dyslexia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSupportSection(),
          const SizedBox(height: 24),
          _buildIndicatorsSection(),
          const SizedBox(height: 24),
          _buildSection(
            title: 'Early Childhood (3-6 yrs)',
            points: [
              'Late talking',
              'Trouble learning nursery rhymes',
              'Difficulty recognizing rhyming patterns',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Primary School Age (6-12 yrs)',
            points: [
              'Confuses similar-looking letters (b/d, p/q)',
              'Poor spelling and reading fluency',
              'Avoids reading out loud',
              'Trouble remembering sequences (e.g., days of the week)',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Teens and Adults',
            points: [
              'Reading takes great effort',
              'Misspells commonly known words',
              'Difficulty summarizing or organizing ideas',
              'Struggles with time management',
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Cognitive Signs (Any Age)',
            points: [
              'Strong long-term memory but poor short-term memory',
              'Good oral expression but weak writing skills',
              'Easily distracted, especially by text-heavy environments',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Our App Supports',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2C3A),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.check_circle,
                label: 'Handwriting Analysis',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.check_circle,
                label: 'Brain Mri Analysis',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Color(0xFF3F51B5), size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Signs and Indicators of Dyslexia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2C3A),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          title: 'Early Years',
          content:
              'Difficulty learning nursery rhymes, slow speech development, muddling words, difficulty keeping rhythm, and forgetting names or colors.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Primary School Age',
          content:
              'Slow processing speed, poor concentration, difficulty following instructions, and messy written work with reversals and bizarre spellings.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'Adults',
          content:
              'Difficulty with reading comprehension, spelling, and organization; visual-spatial confusion like left/right; and avoidance of certain tasks.',
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          title: 'General Signs',
          content:
              'Phonological Awareness, Naming Speed, Decoding Skills, Poor Fluency, Poor Spelling, Difficulty concentrating, Poor comprehension, and Handwriting issues.',
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> points,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                point,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
