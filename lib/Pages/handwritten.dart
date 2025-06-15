import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HandwrittenImagePage extends StatefulWidget {
  const HandwrittenImagePage({super.key});

  @override
  State<HandwrittenImagePage> createState() => _HandwrittenImagePageState();
}

class _HandwrittenImagePageState extends State<HandwrittenImagePage> {
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _predictionResult;
  double? _probability;

  int _age = 0;
  String? _selectedAgeGroup;
  String? _knownDiagnosis;
  String? _letterDifficulty;
  String? _writingConditions;
  String? _gender; // Added gender field

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _uploadProgress = 0.0;
          _isUploading = true;
        });
        await Future.delayed(const Duration(milliseconds: 300));
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 50));
          setState(() {
            _uploadProgress = i / 10;
          });
        }
        setState(() => _isUploading = false);
      }
    } catch (e) {
      _showSnackBar("Image selection failed: ${e.toString()}");
    }
  }

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _uploadProgress = 0.0;
    });
  }

  Future<void> _submit() async {
    if (_imageBytes == null) {
      _showSnackBar("No image selected");
      return;
    }

    if (_age <= 0 ||
        _selectedAgeGroup == null ||
        _knownDiagnosis == null ||
        _letterDifficulty == null ||
        _writingConditions == null ||
        _gender == null) {
      // Added gender check
      _showSnackBar(" Please complete all form fields");
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = null;
      _probability = null;
    });

    try {
      const serverUrl = 'http://192.168.1.13:5000/predict-handwriting';
      final request = http.MultipartRequest('POST', Uri.parse(serverUrl));
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: 'upload.jpg',
      ));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final decoded = json.decode(responseBody);
        final prediction = decoded['prediction'];
        final probability = decoded['probability']?.toDouble();

        setState(() {
          _predictionResult = prediction;
          _probability = probability;
        });

        final imageBase64 = base64Encode(_imageBytes!);
        await _savePredictionToFirestore(imageBase64, prediction, probability);
        _showSnackBar('Prediction saved successfully!');
      } else {
        _showSnackBar('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePredictionToFirestore(
      String imageBase64, String prediction, double? probability) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('predictionsHandwriting')
        .add({
      'imageBase64': imageBase64,
      'prediction': prediction,
      'probability': probability,
      'age': _age,
      'ageGroup': _selectedAgeGroup,
      'knownDiagnosis': _knownDiagnosis,
      'letterDifficulty': _letterDifficulty,
      'writingConditions': _writingConditions,
      'gender': _gender, // Added gender to Firestore
      'timestamp': Timestamp.now(),
    });
  }

  void _showSnackBar(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 12,
          backgroundColor: const Color(0xFFF9FAFC),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text("Skip for now",
                  style: TextStyle(color: Colors.blueAccent, fontSize: 14)),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF9FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload Handwritten Image",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Upload a photo of handwritten text to analyze.",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (_isUploading)
                    Column(
                      children: [
                        const Icon(Icons.file_present, size: 40),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 10),
                        Text(
                            'Uploading Document... ${(100 * _uploadProgress).toInt()}%'),
                      ],
                    )
                  else if (_imageBytes != null)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.check_circle,
                                size: 24, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Upload Complete',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          label: const Text("Clear Upload",
                              style: TextStyle(color: Colors.red)),
                        ),
                        SizedBox(
                          width: 200,
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              _imageBytes!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: const [
                          Icon(Icons.cloud_upload_outlined,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('Tap to upload photo\nPNG, JPG, or JPEG',
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildFormFields(),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF335e96),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 25,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Submit Image",
                        style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),
            if (_predictionResult != null)
              Center(
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D2A38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Prediction",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500)),
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 20),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text("$_predictionResult",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 6),
                      Text("Probability:",
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[300])),
                      Text("${(_probability! * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Please provide the following information to help with analysis:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Age of the writer',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) =>
                setState(() => _age = int.tryParse(value) ?? 0),
          ),
          const SizedBox(height: 16),
          _buildRadioGroup(
            title: 'Gender',
            options: ['Male', 'Female', 'Other'],
            groupValue: _gender,
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 16),
          _buildRadioGroup(
            title: 'Is the handwriting from a child or adult?',
            options: ['Child', 'Adult'],
            groupValue: _selectedAgeGroup,
            onChanged: (value) => setState(() => _selectedAgeGroup = value),
          ),
          const SizedBox(height: 16),
          _buildRadioGroup(
            title: 'Any known diagnosis of dyslexia?',
            options: ['Yes', 'No', 'Not sure'],
            groupValue: _knownDiagnosis,
            onChanged: (value) => setState(() => _knownDiagnosis = value),
          ),
          const SizedBox(height: 16),
          _buildRadioGroup(
            title:
                'Did the writer experience difficulty with letter reversals or spelling?',
            options: ['Yes', 'No'],
            groupValue: _letterDifficulty,
            onChanged: (value) => setState(() => _letterDifficulty = value),
          ),
          const SizedBox(height: 16),
          _buildRadioGroup(
            title: 'Was the writing done under normal conditions?',
            options: ['Yes', 'No'],
            groupValue: _writingConditions,
            onChanged: (value) => setState(() => _writingConditions = value),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup({
    required String title,
    required List<String> options,
    required String? groupValue,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...options.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: groupValue,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }
}
