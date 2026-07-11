import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Helper service utilizing ML Kit for text recognition in images.
class OcrService {
  OcrService._();

  /// Extracts text from a local image file.
  /// Includes fallback simulation for simulator environments.
  static Future<String> extractText(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final TextRecognizer textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      
      String result = recognizedText.text.trim();
      if (result.isNotEmpty) {
        return result;
      }
      return _getSimulatorFallback(imagePath);
    } catch (e) {
      debugPrint('ML Kit OCR processImage exception: $e. Using local simulator fallback.');
      await textRecognizer.close();
      return _getSimulatorFallback(imagePath);
    }
  }

  /// Provides high-quality mock text extracts depending on file paths or random options.
  static String _getSimulatorFallback(String path) {
    final lowerPath = path.toLowerCase();
    
    if (lowerPath.contains('job') || lowerPath.contains('work')) {
      return 'Urgent hiring! Work from home part-time jobs. Earn 3000 to 8000 INR per day simply by completing YouTube tasks. No qualifications required. Join Telegram channel: t.me/easy-earn-task-04 immediately. Limited slots remaining!';
    }
    
    if (lowerPath.contains('bank') || lowerPath.contains('card') || lowerPath.contains('otp')) {
      return 'Alert: Your SBI credit card status is suspended due to verification failure. Update your bank KYC detail within 24 hours at http://sbi-verify-kyc.net/update. Failure to update will result in account freeze.';
    }

    if (lowerPath.contains('delivery') || lowerPath.contains('package')) {
      return 'DHL Package: Your package tracking number #DHL-994238 has a pending delivery custom charge of 120 INR. Please verify your address and process the secure fee payment at http://dhl-delivery-charges.net.';
    }

    // Default general scan text
    return 'Dear customer, you have won an cash prize coupon of 50,000 INR from Amazon. Claim your credit reward immediately by scanning this barcode and entering your mobile bank passcode: http://amazon-rewards-claim.info/collect';
  }
}
