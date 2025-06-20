import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dyslexify/Pages/yourReport.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dyslexify/Components/Drawer_navigation.dart';
// import your modified YourReport page here

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int _currentIndex = 1;
  int _selectedTabIndex = 0;

  Future<List<Map<String, dynamic>>> _fetchCombinedPredictions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final handwritingSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('predictionsHandwriting')
        .get();

    final mriSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('predictionsMri')
        .get();

    final allDocs = [...handwritingSnapshot.docs, ...mriSnapshot.docs];

    final combined = allDocs.map((doc) {
      final data = doc.data();
      data['source'] = doc.reference.parent.id;
      return data;
    }).toList();

    combined.sort((a, b) {
      final tsA = a['timestamp'] as Timestamp?;
      final tsB = b['timestamp'] as Timestamp?;
      return (tsB?.millisecondsSinceEpoch ?? 0)
          .compareTo(tsA?.millisecondsSinceEpoch ?? 0);
    });

    return combined;
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 0),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? const Color(0xFF335e96)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'MRI Reports',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedTabIndex == 0
                          ? Colors.white
                          : Colors.grey[800],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = 1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? const Color(0xFF335e96)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Handwriting Reports',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedTabIndex == 1
                          ? Colors.white
                          : Colors.grey[800],
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

  Widget _buildReportCard(Map<String, dynamic> data) {
    final base64Image = data['imageBase64'] ?? '';
    final prediction = data['prediction']?.toString() ?? 'Unknown';
    final probabilityValue = data['probability'];
    final source = data['source'] ?? 'Unknown';

    double probability = 0.0;
    if (probabilityValue is int) {
      probability = probabilityValue.toDouble();
    } else if (probabilityValue is double) {
      probability = probabilityValue;
    }

    Uint8List? imageBytes;
    try {
      imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;
    } catch (_) {
      imageBytes = null;
    }

    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFF335e96),
          width: 1,
        ),
      ),
      shadowColor: const Color(0xFF335e96),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YourReport(predictionData: data),
            ),
          );
        },
        contentPadding: const EdgeInsets.all(12),
        leading: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.image_not_supported,
                size: 40, color: Colors.grey),
        title: Text(
          'Prediction: $prediction',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: prediction.toLowerCase() == 'dyslexic'
                ? Colors.red
                : Colors.green,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Probability: ${(probability * 100).toStringAsFixed(1)}%'),
            Text('Date: ${_formatDate(data['timestamp'])}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF335e96).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF335e96),
          ),
        ),
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown date';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dyslexia Reports'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E2C3A),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCombinedPredictions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Reports Found"));
          }

          final predictions = snapshot.data!;
          final mriReports = predictions
              .where((report) => report['source'] == 'predictionsMri')
              .toList();
          final handwritingReports = predictions
              .where((report) => report['source'] == 'predictionsHandwriting')
              .toList();

          return Column(
            children: [
              _buildTabBar(),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    // MRI Reports Tab
                    mriReports.isEmpty
                        ? const Center(child: Text("No MRI Reports Found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: mriReports.length,
                            itemBuilder: (context, index) =>
                                _buildReportCard(mriReports[index]),
                          ),
                    // Handwriting Reports Tab
                    handwritingReports.isEmpty
                        ? const Center(
                            child: Text("No Handwriting Reports Found"))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: handwritingReports.length,
                            itemBuilder: (context, index) =>
                                _buildReportCard(handwritingReports[index]),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
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
}
