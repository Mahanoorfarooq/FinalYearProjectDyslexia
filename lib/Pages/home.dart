import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexify/Components/Drawer_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String? fullName;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        fullName = doc.data()?['fullName'] ?? 'User';
      });
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      drawer: CustomDrawer(
        onItemSelected: (index) {
          Navigator.pop(context); // Close drawer
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/reports');
              break;
            case 2:
              Navigator.pushNamed(context, '/about');
              break;
            case 3:
              Navigator.pushNamed(context, '/contact');
              break;
            case 4:
              Navigator.pushNamed(context, '/faq');
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF1E2C3A),
                          width: 1.0,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.menu, color: Color(0xFF1E2C3A)),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                  ),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2C3A),
                    ),
                  ),
                  // New Avatar with Initials and Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF1E2C3A),
                        child: Text(
                          _getInitials(fullName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(0xFF9C6BFF), // Purple dot
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),
              Card(
                color: Color(0xFF1E2C3A), // Dark background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            fullName ?? 'Loading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 5),
                          Icon(Icons.waving_hand,
                              color: Colors.amberAccent, size: 26),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Info Card
              Card(
                color: const Color(0xFFeef5ff),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Color(0xFF335e96)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Did you know? Dyslexia affects about 10% of the population worldwide, with males diagnosed roughly 3 times more than females.',
                          style:
                              TextStyle(color: Color(0xFF335e96), fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Text(
                'Explore Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF335e96),
                ),
              ),
              // Feature Cards
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 3,
                crossAxisSpacing: 3,
                childAspectRatio: 0.8,
                children: [
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.circleInfo,
                    title: "What is Dyslexia?",
                    onTap: () => Navigator.pushNamed(context, '/dyslexia'),
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.search,
                    title: "How to Identify Dyslexia",
                    onTap: () =>
                        Navigator.pushNamed(context, '/identifyDyslexia'),
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.filePen,
                    title: 'Writing Image Analysis',
                    onTap: () =>
                        Navigator.pushNamed(context, '/uploadHandwriting'),
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.brain,
                    title: 'Brain MRI Image Analysis',
                    onTap: () => Navigator.pushNamed(context, '/uploadmri'),
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.chartLine,
                    title: 'View Reports',
                    onTap: () => Navigator.pushNamed(context, '/reports'),
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.lightbulb,
                    title: 'Tips & Tricks',
                    onTap: () => Navigator.pushNamed(context, '/tips'),
                  ),
                ],
              ),

              const SizedBox(height: 35),
              _buildSectionTitle('Dyslexia Diagnosis by Gender',
                  'Males are diagnosed about 3 times more often than females.'),
              const SizedBox(height: 12),

              // Pie Chart
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: Color(0xFF335e96),
                              value: 75,
                              radius: 40,
                              title: '75%',
                              titleStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              color: Colors.pink.shade300,
                              value: 25,
                              radius: 40,
                              title: '25%',
                              titleStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                          sectionsSpace: 0,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _colorIndicator(Color(0xFF335e96), 'Males'),
                        const SizedBox(height: 10),
                        _colorIndicator(Colors.pink.shade300, 'Females'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              _buildSectionTitle('Dyslexia Prevalence in Pakistan Over Time',
                  'Steady increase in dyslexia prevalence over the past decade'),
              const SizedBox(height: 12),

              // Pakistan Trend Chart
              SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: 12,
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('2010',
                                    style: TextStyle(fontSize: 12));
                              case 1:
                                return const Text('2015',
                                    style: TextStyle(fontSize: 12));
                              case 2:
                                return const Text('2018',
                                    style: TextStyle(fontSize: 12));
                              case 3:
                                return const Text('2020',
                                    style: TextStyle(fontSize: 12));
                              case 4:
                                return const Text('2023',
                                    style: TextStyle(fontSize: 12));
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 2,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 4.8), // 2010
                          FlSpot(1, 6.2), // 2015
                          FlSpot(2, 7.5), // 2018
                          FlSpot(3, 9.1), // 2020
                          FlSpot(4, 11.0), // 2023
                        ],
                        isCurved: true,
                        color: Colors.teal.shade700,
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.teal.shade100.withOpacity(0.5),
                        ),
                        dotData: FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
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

  Widget _colorIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF335e96),
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF335e96), width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF335e96)),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF335e96),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF335e96),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF545454),
          ),
        ),
      ],
    );
  }
}
