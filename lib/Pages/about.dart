import 'package:dyslexify/Components/Drawer_navigation.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  int _currentIndex = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E2C3A)),
          onPressed: () => Navigator.pop(context, "/home"),
        ),
        centerTitle: true,
        title: const Text(
          'About App Usage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFF1E2C3A),
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('About This App'),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Dyslexify is built to support early detection of dyslexia using modern AI technologies. '
                'It empowers parents, teachers, and healthcare professionals by providing simple tools to upload and analyze MRI brain scans or handwriting samples.'
                '\n\nThe app uses deep learning models to detect signs that may relate to dyslexia, offering early awareness and support.',
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('How to Use Dyslexify'),
              const SizedBox(height: 12),
              _buildStepCard(
                number: 1,
                title: 'Upload an MRI Image',
                content:
                    '• Go to the "MRI Image Analysis" section from the Home screen.\n'
                    '• Tap on the upload button.\n'
                    '• Choose a brain MRI scan from your device.\n'
                    '• Make sure the image is clear and in a supported format (JPG, PNG).',
                icon: Icons.file_upload,
              ),
              _buildStepCard(
                number: 2,
                title: 'Upload a Handwritten Image',
                content: '• Visit the "Handwriting Image Analysis" section.\n'
                    '• Tap the upload button to select a photo.\n'
                    '• choose an image of a child’s handwritten letter.\n'
                    '• Ensure the handwriting is centered and visible.',
                icon: Icons.draw,
              ),
              _buildStepCard(
                number: 3,
                title: 'Wait for Processing',
                content: '• After uploading, your image will be analyzed.\n'
                    '• This process may take a few seconds.\n'
                    '• Once complete, a result will appear indicating if signs of dyslexia are present.',
                icon: Icons.hourglass_bottom,
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('To Know More About Dyslexia'),
              const SizedBox(height: 12),
              Center(
                child: SizedBox(
                  width:
                      170, // Set to your desired width instead of double.infinity
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/dyslexia');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF335e96),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Visit Dyslexia Page',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('Viewing Reports'),
              const SizedBox(height: 12),
              _buildInfoCard(
                'To view your analysis history, open the side menu (Drawer) and tap on "My Tests".\n\n'
                'Alternatively, go to the Home page and tap on "View Reports". '
                'This will show all previous image uploads along with predictions, confidence scores, and timestamps.',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  // Section Header without icon
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E2C3A),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, height: 1.6),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  // Step card with spacing and icon
  Widget _buildStepCard({
    required int number,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF335e96),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E2C3A),
                    ),
                  ),
                ),
                Icon(icon, color: const Color(0xFF335e96), size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 42.0),
              child: Text(
                content,
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
