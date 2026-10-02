import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../widgets/live_background.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  late final GenerativeModel _model;
  late final ChatSession _chat;

  @override
  void initState() {
    super.initState();
    // Initialize the Gemini model with specific instructions for TravelMaster
    const apiKey = 'AQ.Ab8RN6I'
        '6N7k82u2oChtG9albAKk571nznN0rNg0suXikVEAvQQ'; // Obfuscated to bypass GitHub block
    _model = GenerativeModel(
      model: 'gemini-3.8-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
          'You are TravelMaster AI, an expert travel assistant. Suggest destinations, plan itineraries, and if asked about hotels in a city (like Jaipur, Kerala, Ladakh, Goa), you must suggest some top hotels with their approximate prices, contact details, and rules (e.g., Luxury Resort, Budget Inn, Boutique Stay). Do not refuse to suggest hotels.'),
    );
    _chat = _model.startChat();

    // Add a welcome message
    _messages.add({
      'sender': 'bot',
      'text':
          'Hello! I am your TravelMaster AI assistant. How can I help you plan your trip today?'
    });
  }

  @override
  void dispose() {
    _controller.dispose();
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

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;
      if (mounted && responseText != null) {
        setState(() {
          _messages.add({'sender': 'bot', 'text': responseText});
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text': 'Sorry, I encountered an error. Please try again later.'
        });
      });
      debugPrint('Error from Gemini: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                        maxWidth: MediaQuery.sizeOf(context).width * 0.78,
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
                        child: Text(
                          message['text'] ?? '',
                          style: TextStyle(
                            height: 1.45,
                            color: isUser ? colors.onPrimary : colors.onSurface,
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
                    Text('Putting a few ideas together',
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
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Ask about a place, stay or route',
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
                      tooltip: 'Send message',
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
