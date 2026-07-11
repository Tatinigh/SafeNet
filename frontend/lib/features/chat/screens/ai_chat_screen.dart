import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_theme.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    await ref.read(chatProvider.notifier).sendMessage(text.trim());
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final stats = ref.watch(dashboardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Trigger scroll when lists update
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Text(
                  'SafeNet AI',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            // Safety Score Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '🛡 ${stats.safetyScore}',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: () {
              ref.read(chatProvider.notifier).clearHistory();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat history cleared.')),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        child: Column(
          children: [
            // Chat Conversation List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: chatState.messages.length,
                itemBuilder: (context, index) {
                  final message = chatState.messages[index];
                  return _buildMessageBubble(message, isDark);
                },
              ),
            ),

            // AI Typing indicator
            if (chatState.isTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondaryColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI is typing...',
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textLightColor),
                    ),
                  ],
                ),
              ),

            // Suggestion Chips (Image 2)
            if (chatState.messages.length <= 2)
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: chatState.suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = chatState.suggestions[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8, bottom: 8),
                      child: ActionChip(
                        label: Text(suggestion),
                        onPressed: () => _handleSendMessage(suggestion),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.withOpacity(0.15)),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Bottom Message Input Bar (Image 2)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppTheme.softShadows,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    // Plus Icon (Image 2)
                    IconButton(
                      icon: const Icon(Icons.add, color: AppTheme.textLightColor),
                      onPressed: () {
                        // Quick scan attachments shortcut
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Media upload shortcuts coming soon.')),
                        );
                      },
                    ),
                    
                    // Input Text Field
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        style: GoogleFonts.inter(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ask anything about security...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onSubmitted: _handleSendMessage,
                      ),
                    ),
                    
                    // Dark Blue Send Button (Image 2)
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryColor,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: () => _handleSendMessage(_textController.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Beautiful User vs AI card formatting matching Image 2 mockup
  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final isUser = message.role == 'user';

    if (isUser) {
      // User bubble: Dark blue on the right (Image 2)
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 48, bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            boxShadow: AppTheme.softShadows,
          ),
          child: Text(
            message.text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      // AI response: White card, left-aligned, blue/cyan label (Image 2)
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(right: 32, bottom: 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: AppTheme.softShadows,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: 🛡 SAFENET AI VERIFIED (Image 2)
              Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppTheme.secondaryColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'SAFENET AI VERIFIED',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondaryColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Text Content (Highlight warnings like 'scam' in red)
              _buildRichScamText(message.text, isDark),
              
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Bottom footer link: Learn more about banking security (Image 2)
              InkWell(
                onTap: () {
                  // Direct to learning category
                },
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppTheme.secondaryColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Learn more about banking security',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // Highlight words like 'scam', 'fraud', 'steal', 'otp' in red color (as shown in Image 2)
  Widget _buildRichScamText(String rawText, bool isDark) {
    if (rawText.isEmpty) {
      return const SizedBox(
        width: 40,
        height: 14,
        child: LinearProgressIndicator(color: AppTheme.secondaryColor, minHeight: 2),
      );
    }

    final words = rawText.split(' ');
    final List<TextSpan> spans = [];

    for (var word in words) {
      final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      final isScamTerm = cleanWord == 'scam' ||
          cleanWord == 'scams' ||
          cleanWord == 'fraud' ||
          cleanWord == 'phishing' ||
          cleanWord == 'otp' ||
          cleanWord == 'fake';

      spans.add(
        TextSpan(
          text: '$word ',
          style: TextStyle(
            color: isScamTerm
                ? AppTheme.dangerColor
                : (isDark ? Colors.white70 : AppTheme.textDarkColor),
            fontWeight: isScamTerm ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.inter(fontSize: 14, height: 1.45),
        children: spans,
      ),
    );
  }
}
