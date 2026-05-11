import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../services/database_helper.dart';

class ScanProvider with ChangeNotifier {
  XFile? _currentImage;
  Uint8List? _imageBytes;
  Map<String, dynamic>? _predictionResult;
  bool _isAnalyzing = false;

  XFile? get currentImage => _currentImage;
  Uint8List? get imageBytes => _imageBytes;
  Map<String, dynamic>? get predictionResult => _predictionResult;
  bool get isAnalyzing => _isAnalyzing;

  // Use the API key from your .env
  final String _apiKey = 'AIzaSyCkcqa-F_XTBt-HNAkdzyMdiCBIqgVCqok';

  Future<void> setImage(XFile image) async {
    _currentImage = image;
    _imageBytes = await image.readAsBytes();
    _predictionResult = null;
    notifyListeners();
  }

  Future<bool> analyzeImage() async {
    if (_currentImage == null || _imageBytes == null) return false;

    _isAnalyzing = true;
    notifyListeners();

    try {
      final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
      
      final content = [
        Content.multi([
          TextPart("""
            Analyze this maize (corn) leaf image for diseases. 
            Return ONLY a JSON object with the following keys:
            - "plant": The plant type (should be "Corn (maize)").
            - "disease": The specific disease name (e.g., "Northern Leaf Blight", "Common Rust", "Maize Streak Virus") or "healthy".
            - "confidence": A float between 0 and 100 representing your certainty.
            - "is_maize": Boolean, true if the image is actually a maize plant.
            - "symptoms": An array of strings describing the symptoms.
            - "recommendations": An array of strings for treatment.
            - "health_index": An integer from 0 to 100.
          """),
          DataPart('image/jpeg', _imageBytes!),
        ])
      ];

      final response = await model.generateContent(content);
      String text = response.text ?? '{}';
      
      // Clean JSON
      if (text.contains('```json')) {
        text = text.split('```json')[1].split('```')[0].trim();
      } else if (text.contains('```')) {
        text = text.split('```')[1].split('```')[0].trim();
      }

      final result = json.decode(text);
      
      _predictionResult = {
        'prediction': result,
      };

      // Save to local database
      await DatabaseHelper().insertScan({
        'disease': result['disease'],
        'confidence': result['confidence'],
        'health_index': result['health_index'],
        'image_path': _currentImage!.path,
        'timestamp': DateTime.now().toIso8601String(),
        'symptoms': json.encode(result['symptoms']),
        'recommendations': json.encode(result['recommendations']),
      });

      _isAnalyzing = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Gemini Analysis error: $e');
    }

    _isAnalyzing = false;
    notifyListeners();
    return false;
  }
}
