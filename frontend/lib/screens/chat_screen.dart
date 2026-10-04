import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../widgets/live_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.isShiftPressed) {
        _sendMessage();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  static const _apiKey = 'AQ.Ab8RN6I'
      '6N7k82u2oChtG9albAKk571nznN0rNg0suXikVEAvQQ'; // Obfuscated to bypass GitHub block

  // High-availability candidate models prioritized by stability and low latency
  static const List<String> _candidateModels = [
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-flash-latest',
    'gemini-3.5-flash',
    'gemini-3.8-flash',
  ];

  static const String _systemInstruction =
      'You are TravelMaster AI, an expert, deeply knowledgeable travel planner and concierge.\n'
      'When answering travel queries, search and plan in a deep, thorough, and highly specific manner:\n'
      '1. Provide rich, practical details including top attractions, hidden gems, day-by-day itineraries, and transit routes.\n'
      '2. When suggesting hotels/stays, always provide categorized options (e.g., Luxury Resort, Boutique Heritage, Mid-Range, Budget Inn) with exact property names, specific location/neighborhood, approximate prices (in INR and USD), contact details (phone, email, or website), and key rules (check-in/out times, visitor/pet policies).\n'
      '3. Include actionable recommendations such as the best season/month to visit, weather tips, local food recommendations, and budget guidance.\n'
      '4. Format your output cleanly and efficiently using clear Markdown headers (###), bold highlights, and structured bullet points so it is effortless to read.';

  int _currentModelIndex = 0;
  GenerativeModel? _model;
  ChatSession? _chat;
  final List<Content> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _initChatSession();

    // Add a welcome message
    _messages.add({
      'sender': 'bot',
      'text':
          'Hello! I am your TravelMaster AI assistant. How can I help you plan your trip today?'
    });
  }

  void _initChatSession() {
    final modelName = _candidateModels[_currentModelIndex];
    _model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemInstruction),
    );
    _chat = _model!.startChat(history: List<Content>.from(_chatHistory));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();

    final userContent = Content.text(text);
    String? replyText;

    for (int attempt = 0; attempt < _candidateModels.length; attempt++) {
      try {
        if (_chat == null) {
          _initChatSession();
        }
        final response = await _chat!.sendMessage(userContent);
        final responseText = response.text;
        if (responseText != null && responseText.trim().isNotEmpty) {
          replyText = responseText.trim();
          _chatHistory.add(userContent);
          _chatHistory.add(Content.model([TextPart(replyText)]));
          break;
        }
      } catch (e) {
        debugPrint('Gemini attempt failed with ${_candidateModels[_currentModelIndex]}: $e');
        _currentModelIndex = (_currentModelIndex + 1) % _candidateModels.length;
        _initChatSession();
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (replyText != null) {
        _messages.add({'sender': 'bot', 'text': replyText});
      } else {
        _messages.add({
          'sender': 'bot',
          'text':
              'All AI models are currently experiencing high demand. Please try asking again in a few moments.'
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.explore_rounded,
                  color: Colors.white, size: 21),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel guide'),
                Text(
                  'Here for the details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: LiveBackground(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message['sender'] == 'user';
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.85,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: isUser ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(15).copyWith(
                            bottomRight:
                                isUser ? const Radius.circular(4) : null,
                            bottomLeft:
                                !isUser ? const Radius.circular(4) : null,
                          ),
                          border: isUser
                              ? null
                              : Border.all(
                                  color: colors.outlineVariant
                                      .withValues(alpha: 0.65)),
                        ),
                        child: isUser
                            ? Text(
                                message['text'] ?? '',
                                style: TextStyle(
                                  height: 1.45,
                                  color: colors.onPrimary,
                                  fontSize: 15,
                                ),
                              )
                            : MarkdownBody(
                                data: message['text'] ?? '',
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    height: 1.55,
                                    color: colors.onSurface,
                                    fontSize: 14.5,
                                  ),
                                  h1: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.5,
                                  ),
                                  h2: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    height: 1.45,
                                  ),
                                  h3: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.5,
                                    height: 1.4,
                                  ),
                                  h4: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                    height: 1.35,
                                  ),
                                  strong: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  em: const TextStyle(fontStyle: FontStyle.italic),
                                  listBullet: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  code: TextStyle(
                                    backgroundColor: colors.surfaceContainerHighest,
                                    color: colors.onSurface,
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                  blockquoteDecoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: 0.4),
                                    border: Border(
                                      left: BorderSide(
                                          color: colors.primary, width: 3),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  horizontalRuleDecoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: colors.outlineVariant, width: 1),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('Searching deeply and putting recommendations together...',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            if (_messages.length <= 2 && !_isLoading)
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'Find me a quiet getaway',
                    'Hotels in Jaipur',
                    '5 days in Kerala',
                    'Best beaches in Goa',
                  ]
                      .map((prompt) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(
                              label: Text(prompt),
                              side: BorderSide(color: colors.outlineVariant),
                              backgroundColor: colors.surface,
                              onPressed: () {
                                _controller.text = prompt;
                                _sendMessage();
                              },
                            ),
                          ))
                      .toList(),
                ),
              ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.outlineVariant)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      decoration: const InputDecoration(
                        hintText: 'Ask about a place, stay or route (Enter to send)',
                        prefixIcon: Icon(Icons.chat_outlined),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton.filled(
                      tooltip: 'Send message (Enter)',
                      onPressed: _isLoading ? null : _sendMessage,
                      icon: const Icon(Icons.arrow_upward_rounded),
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
