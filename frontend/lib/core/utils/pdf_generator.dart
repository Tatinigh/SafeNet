import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../services/api_client.dart';
import '../../features/analysis/models/analysis_report.dart';

/// Utility to generate structured PDF reports for scan analyses.
class PdfGenerator {
  PdfGenerator._();

  /// Generates a PDF file from an [AnalysisReport] and returns its file path.
  static Future<File> generateReport(AnalysisReport report) async {
    final pdf = pw.Document();

    // Custom styles
    final primaryColor = PdfColor.fromHex('#1E3A8A');
    final dangerColor = PdfColor.fromHex('#EF4444');
    final warningColor = PdfColor.fromHex('#F59E0B');
    final successColor = PdfColor.fromHex('#22C55E');
    final textColor = PdfColor.fromHex('#0F172A');
    final lightColor = PdfColor.fromHex('#475569');

    final riskColor = report.riskScore >= 75
        ? dangerColor
        : report.riskScore >= 40
            ? warningColor
            : successColor;

    final riskBgColor = report.riskScore >= 75
        ? PdfColor.fromHex('#FEE2E2')
        : report.riskScore >= 40
            ? PdfColor.fromHex('#FEF3C7')
            : PdfColor.fromHex('#DCFCE7');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SafeNet AI - Threat Analysis Report',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated on: ${report.timestamp.toLocal()}',
                        style: pw.TextStyle(fontSize: 10, color: lightColor),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: primaryColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      'VERIFIED REPORT',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Divider(color: PdfColors.grey300, thickness: 1, height: 24),

              // Threat Level Summary Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: riskBgColor,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: riskColor, width: 1.5),
                ),
                child: pw.Row(
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '${report.riskScore}% RISK SCORE',
                          style: pw.TextStyle(
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'STATUS: ${report.status.toUpperCase()}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    pw.Spacer(),
                    pw.Container(
                      width: 50,
                      height: 50,
                      alignment: pw.Alignment.center,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        color: riskColor,
                      ),
                      child: pw.Text(
                        '${report.confidence}%',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Analyzed Content
              pw.Text(
                'Scanned Content Source (${report.scanType})',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  report.content.isNotEmpty ? report.content : 'No text content available.',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                ),
              ),
              pw.SizedBox(height: 20),

              // AI Summary
              pw.Text(
                'AI Explanation Summary',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                report.summary,
                style: pw.TextStyle(fontSize: 11, color: textColor),
              ),
              pw.SizedBox(height: 20),

              // Scam DNA Profile
              pw.Text(
                'Scam DNA threat vectors profile',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildDnaRow('Urgency', report.scamDna.urgency),
                  _buildDnaRow('Fear Tactic', report.scamDna.fear),
                  _buildDnaRow('Money Demand', report.scamDna.money),
                  _buildDnaRow('Identity Theft', report.scamDna.identity),
                  _buildDnaRow('Fake Branding', report.scamDna.branding),
                ],
              ),
              pw.SizedBox(height: 20),

              // Flagged Indicators (Reasons)
              pw.Text(
                'Flagged Risk Indicators',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              pw.ListView.builder(
                itemCount: report.reasons.length,
                itemBuilder: (context, index) {
                  final reason = report.reasons[index];
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Bullet(bulletColor: dangerColor),
                        pw.SizedBox(width: 8),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '${reason.title} (${reason.severity} Severity)',
                                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: textColor),
                              ),
                              pw.Text(
                                reason.description,
                                style: pw.TextStyle(fontSize: 9, color: lightColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              pw.SizedBox(height: 16),

              // Security Recommendations
              pw.Text(
                'Recommended Safety Measures',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor),
              ),
              pw.SizedBox(height: 6),
              ...report.recommendations.map((rec) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Row(
                      children: [
                        pw.Text('✓ ', style: pw.TextStyle(color: successColor, fontSize: 12)),
                        pw.Text(rec, style: pw.TextStyle(fontSize: 10, color: textColor)),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );

    // Save PDF to temp folder
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/safenet_report_${report.id}.pdf';
    final file = File(path);
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildDnaRow(String label, int value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
        pw.SizedBox(height: 2),
        pw.Text('$value%', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }
}
