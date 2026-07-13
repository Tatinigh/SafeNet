import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/ocr_service.dart';

class OcrEditorScreen extends StatefulWidget {
  final String imagePath;
  final String scanType;

  const OcrEditorScreen({
    super.key,
    required this.imagePath,
    required this.scanType,
  });

  @override
  State<OcrEditorScreen> createState() => _OcrEditorScreenState();
}

class _OcrEditorScreenState extends State<OcrEditorScreen> {
  final _textController = TextEditingController();
  bool _isExtracting = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _performOcr();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _performOcr() async {
    try {
      final text = await OcrService.extractText(widget.imagePath);
      setState(() {
        _textController.text = text;
        _isExtracting = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Could not perform OCR. Please type the message manually.';
        _isExtracting = false;
      });
    }
  }

  void _onStartScan() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.push('/ai-loading', extra: {
        'input': text,
        'scanType': widget.scanType,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Extracted Text'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Preview Card
            ClipRRect(
              borderRadius: AppTheme.cardBorderRadius,
              child: Container(
                height: 150,
                color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                child: kIsWeb
                    ? const Center(
                        child: Icon(
                          Icons.image,
                          size: 70,
                          color: Colors.grey,
                        ),
                      )
                    : widget.imagePath.startsWith('http')
                        ? Image.network(
                            widget.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : Image.file(
                            File(widget.imagePath),
                            fit: BoxFit.cover,
                          ),
              ),
            ),
            const SizedBox(height: 20),

            // OCR Extraction Status
            Row(
              children: [
                Icon(
                  Icons.document_scanner_outlined, 
                  color: _isExtracting ? AppTheme.secondaryColor : AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isExtracting ? 'AI OCR extracting text...' : 'OCR text extracted successfully',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : AppTheme.textDarkColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text Area Input
            if (_isExtracting)
              Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.cardBorderRadius,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(strokeWidth: 3),
                    SizedBox(height: 12),
                    Text('Reading image text...'),
                  ],
                ),
              )
            else
              TextFormField(
                controller: _textController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Edit Extracted Text',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: AppTheme.cardBorderRadius,
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppTheme.cardBorderRadius,
                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.inter(color: AppTheme.dangerColor, fontSize: 13),
                ),
              ),

            // Analyze Button
            ElevatedButton.icon(
              onPressed: _isExtracting ? null : _onStartScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                elevation: 6,
              ),
              icon: const Icon(Icons.shield_outlined),
              label: const Text('Start AI Threat Scan'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
