import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;

class YourReport extends StatefulWidget {
  final Map<String, dynamic> predictionData;

  const YourReport({super.key, required this.predictionData});

  @override
  State<YourReport> createState() => _YourReportState();
}

class _YourReportState extends State<YourReport> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final basicData = userDoc.data() ?? {};

      final source = widget.predictionData['source'] ?? 'Handwriting';
      final subcollectionName =
          source == 'Handwriting' ? 'predictionsHandwriting' : 'predictionsMri';

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(subcollectionName)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final ageFromSubcollection =
          snapshot.docs.isNotEmpty ? snapshot.docs.first.data()['age'] : null;

      setState(() {
        userData = {
          ...basicData,
          'age': ageFromSubcollection ?? 'N/A',
        };
        loading = false;
      });
    } catch (e) {
      setState(() {
        userData = {'age': 'N/A'};
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user details: $e')),
      );
    }
  }

  Future<void> _saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/$fileName.pdf';
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      await OpenFile.open(filePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
      );
    }
  }

  Future<void> _generatePdfAndSave() async {
    final pdf = pw.Document();

    final prediction = widget.predictionData['prediction'] ?? 'Unknown';
    final probability = widget.predictionData['probability'] ?? 0.0;
    final source = widget.predictionData['source'] ?? 'Unknown';
    final base64Image = widget.predictionData['imageBase64'] ?? '';
    Uint8List? imageBytes;

    try {
      imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;
    } catch (_) {
      imageBytes = null;
    }

    final isDyslexic = prediction.toString().toLowerCase() == 'dyslexic';
    final recommendations = isDyslexic
        ? [
            "Daily reading practice for 15–20 minutes.",
            "Weekly sessions with a licensed speech or reading therapist.",
            "Use text-to-speech and dictation tools.",
            "Play phonics-based and multisensory educational games.",
            "Break study tasks into smaller chunks with frequent breaks.",
            "Encourage confidence through positive reinforcement."
          ]
        : [
            "No signs of dyslexia detected.",
            "Maintain regular reading habits.",
            "Encourage book reading and vocabulary enrichment.",
            "Monitor academic progress annually."
          ];

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Dyslexia Report',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Full Name: ${userData?['fullName'] ?? 'N/A'}'),
              pw.Text(
                  'Email: ${FirebaseAuth.instance.currentUser?.email ?? 'N/A'}'),
              pw.Text('Age: ${userData?['age'] ?? 'N/A'}'),
              pw.Text(
                  'Source: ${source == 'predictionsHandwriting' ? 'Handwriting' : 'MRI'}'),
              pw.SizedBox(height: 20),
              pw.Text('Prediction: $prediction'),
              pw.Text(
                  'Probability: ${(probability * 100).toStringAsFixed(1)}%'),
              if (imageBytes != null)
                pw.Center(
                    child: pw.Image(pw.MemoryImage(imageBytes),
                        width: 200, height: 200)),
              pw.SizedBox(height: 20),
              pw.Text('Recommendations:',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              ...recommendations.map((r) => pw.Bullet(text: r)),
            ],
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final base64Pdf = base64Encode(pdfBytes);
    final fileName = 'report_${DateTime.now().millisecondsSinceEpoch}';

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final reportData = {
          'fullName': userData?['fullName'] ?? '',
          'email': user.email,
          'age': userData?['age'] ?? '',
          'prediction': prediction,
          'probability': probability,
          'timestamp': FieldValue.serverTimestamp(),
          'recommendations': recommendations,
          'pdfBase64': base64Pdf,
          'fileName': '$fileName.pdf',
          'source': source,
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('reports')
            .add(reportData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving to Firestore: ${e.toString()}')),
        );
      }
    }

    await _saveAndOpenPdf(pdfBytes, fileName);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final prediction = widget.predictionData['prediction'] ?? 'Unknown';
    final probability = widget.predictionData['probability'] ?? 0.0;
    final base64Image = widget.predictionData['imageBase64'] ?? '';
    final source = widget.predictionData['source'] ?? 'Unknown';

    Uint8List? imageBytes;
    try {
      imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;
    } catch (_) {
      imageBytes = null;
    }

    final isDyslexic = prediction.toString().toLowerCase() == 'dyslexic';
    final recommendations = isDyslexic
        ? [
            "Daily reading practice for 15–20 minutes.",
            "Weekly sessions with a licensed speech or reading therapist.",
            "Use text-to-speech and dictation tools.",
            "Play phonics-based and multisensory educational games.",
            "Break study tasks into smaller chunks with frequent breaks.",
            "Encourage confidence through positive reinforcement."
          ]
        : [
            "No signs of dyslexia detected.",
            "Maintain regular reading habits.",
            "Encourage book reading and vocabulary enrichment.",
            "Monitor academic progress annually."
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Report'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2C3A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Name',
                          style: TextStyle(color: Colors.white70)),
                      Row(
                        children: const [
                          Text('Welcome',
                              style: TextStyle(color: Colors.white70)),
                          SizedBox(width: 6),
                          Icon(Icons.waving_hand, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userData?['fullName'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const Divider(height: 24, color: Colors.white12),
                  _infoRow('Email', FirebaseAuth.instance.currentUser?.email),
                  _infoRow('Age', userData?['age'].toString()),
                  _infoRow(
                      'Source',
                      source == 'predictionsHandwriting'
                          ? 'Handwriting'
                          : 'MRI'),
                ],
              ),
            ),
            Text('Prediction: $prediction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDyslexic ? Colors.red : Colors.green,
                )),
            Text(
              'Probability: ${(probability * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 18),
            ),
            const Divider(height: 30),
            const Text('Recommendations:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                          child:
                              Text(rec, style: const TextStyle(fontSize: 16))),
                    ],
                  ),
                )),
            const SizedBox(height: 30),
            Center(child: _pdfButton()),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Flexible(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pdfButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.download, color: Colors.white),
        label: const Text('View / Download PDF Report'),
        onPressed: _generatePdfAndSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF335e96),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            side: const BorderSide(color: Colors.white24),
          ),
          elevation: 4,
          shadowColor: Colors.black45,
        ),
      ),
    );
  }
}
