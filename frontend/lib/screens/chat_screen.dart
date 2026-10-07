import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add({
      'sender': 'bot',
      'text':
          'Hello! 👋 I am your **TravelMaster AI assistant** powered by live Generative AI.\n\nHow can I help you plan your travel today? Ask me anything about destinations, itineraries, flight/train routes, or hotel recommendations!'
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

    final endpoints = <String>[
      'http://localhost:5000/api/chat',
      'http://127.0.0.1:5000/api/chat',
      if (Uri.base.scheme.startsWith('http')) '${Uri.base.origin}/api/chat',
    ].toSet().toList();

    http.Response? res;
    for (final urlStr in endpoints) {
      try {
        final response = await http.post(
          Uri.parse(urlStr),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'message': text,
            'history': _messages,
          }),
        ).timeout(const Duration(seconds: 25));

        if (response.statusCode == 200) {
          res = response;
          break;
        }
      } catch (e) {
        debugPrint('Failed connecting to AI endpoint $urlStr: $e');
      }
    }

    if (res != null && res.statusCode == 200) {
      try {
        final data = json.decode(res.body);
        if (data['reply'] != null && data['reply'].toString().trim().isNotEmpty) {
          if (mounted) {
            setState(() {
              _messages.add({'sender': 'bot', 'text': data['reply'].toString().trim()});
              _isLoading = false;
            });
            return;
          }
        }
      } catch (e) {
        debugPrint('JSON parse error: $e');
      }
    }

    if (mounted) {
      setState(() {
        _messages.add({
          'sender': 'bot',
          'text':
              '⚠️ Unable to connect to the live AI service. Please check your internet connection and try again.'
        });
        _isLoading = false;
      });
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
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 21),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Travel guide'),
                Text(
                  '100% Live AI Assistant',
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
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isUser ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight:
                                isUser ? const Radius.circular(4) : null,
                            bottomLeft:
                                !isUser ? const Radius.circular(4) : null,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : MarkdownBody(
                                data: message['text'] ?? '',
                                selectable: true,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                      height: 1.5,
                                      color: colors.onSurface,
                                      fontSize: 15),
                                  h1: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                      fontSize: 20),
                                  h2: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                      fontSize: 18),
                                  h3: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                      fontSize: 16),
                                  h4: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface,
                                      fontSize: 15),
                                  strong: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface),
                                  tableBody: TextStyle(
                                      color: colors.onSurface, fontSize: 14),
                                  tableHead: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                      fontSize: 14),
                                  tableBorder: TableBorder.all(
                                      color: colors.outlineVariant, width: 1),
                                  listBullet: TextStyle(
                                      color: colors.primary, fontSize: 16),
                                  code: TextStyle(
                                      backgroundColor:
                                          colors.surfaceContainerHighest,
                                      fontFamily: 'monospace'),
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
                    Text('Live AI is thinking...',
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
