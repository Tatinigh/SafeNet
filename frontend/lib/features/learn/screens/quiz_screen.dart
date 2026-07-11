import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class QuizQuestion {
  final String scenario;
  final String category;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.scenario,
    required this.category,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  int? _selectedAnswerIndex;
  bool _quizFinished = false;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      scenario: 'You receive an SMS: "Your credit card KYC has expired. Update immediately at http://sbi-net-kyc.info to prevent card block within 24 hours."',
      category: 'Phishing',
      options: ['Safe', 'Scam Attempt'],
      correctIndex: 1,
      explanation: 'Banks never request details via SMS using unverified .info URLs. This is phishing trying to steal your account credentials.',
    ),
    QuizQuestion(
      scenario: 'A local taxi driver tells you his QR code scanner is broken and asks you to enter your UPI PIN on a link he sends you so you can "RECEIVE" cash back.',
      category: 'UPI Fraud',
      options: ['Safe', 'Scam Attempt'],
      correctIndex: 1,
      explanation: 'UPI PIN is strictly required to SEND money or make payments. You never need to enter your PIN to receive money or refunds.',
    ),
    QuizQuestion(
      scenario: 'An Instagram recruiter offers you a part-time job watching video advertisements for 5000 INR daily. They request an upfront 350 INR slot registration fee.',
      category: 'Job Scam',
      options: ['Safe', 'Scam Attempt'],
      correctIndex: 1,
      explanation: 'Legitimate employers never demand upfront registration, training, or application fees from employees. This is a task deposit scam.',
    ),
  ];

  void _handleAnswerSelection(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
      }
    });
  }

  void _handleNextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswerIndex = null;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _answered = false;
      _selectedAnswerIndex = null;
      _quizFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_quizFinished) {
      final bool pass = _score == _questions.length;
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz Results')),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Badge Icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: pass ? AppTheme.successColor.withOpacity(0.12) : AppTheme.warningColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    pass ? Icons.verified_user_rounded : Icons.workspace_premium_outlined,
                    size: 80,
                    color: pass ? AppTheme.successColor : AppTheme.warningColor,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Result text
                Text(
                  pass ? 'Scam Buster Badge Unlocked!' : 'Well Played!',
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppTheme.textDarkColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your score: $_score / ${_questions.length}',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    pass 
                        ? 'Congratulations! You answered all scenarios correctly and are certified as a SafeNet Scam Buster.' 
                        : 'Practice makes perfect. Review the tips and try again to unlock your safety badge.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLightColor, height: 1.45),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                ElevatedButton(
                  onPressed: _resetQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Try Again'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Return to School'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Scam IQ - Question ${_currentIndex + 1}/${_questions.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Badge
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.category.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scenario Card
            Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(minHeight: 140),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: AppTheme.cardBorderRadius,
                boxShadow: AppTheme.softShadows,
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Text(
                question.scenario,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppTheme.textDarkColor,
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Options List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _selectedAnswerIndex == index;
                final isCorrectOption = index == question.correctIndex;

                Color optionColor = isDark ? const Color(0xFF1E293B) : Colors.white;
                Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
                IconData? statusIcon;

                if (_answered) {
                  if (isCorrectOption) {
                    optionColor = AppTheme.successColor.withOpacity(0.12);
                    borderColor = AppTheme.successColor;
                    statusIcon = Icons.check_circle_outline;
                  } else if (isSelected) {
                    optionColor = AppTheme.dangerColor.withOpacity(0.12);
                    borderColor = AppTheme.dangerColor;
                    statusIcon = Icons.cancel_outlined;
                  }
                }

                return GestureDetector(
                  onTap: () => _handleAnswerSelection(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: optionColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textDarkColor,
                            ),
                          ),
                        ),
                        if (statusIcon != null)
                          Icon(statusIcon, color: borderColor, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Explanation panel (visible after response)
            if (_answered) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade50,
                  borderRadius: AppTheme.cardBorderRadius,
                  border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Explanation',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.explanation,
                      style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondaryColor, height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _handleNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(_currentIndex == _questions.length - 1 ? 'Finish Quiz' : 'Next Scenario'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
