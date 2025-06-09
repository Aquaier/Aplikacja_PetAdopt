// Strona wiadomości użytkownika, wyświetla listę konwersacji i obsługuje czat.
// Umożliwia przeglądanie, wysyłanie i usuwanie wiadomości oraz konwersacji.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart' show getApiBaseUrl;
import 'favorites_page.dart';

/// Model ostatniej wiadomości w liscie konwersacji
class Message {
  final String sender;
  final String text;
  final DateTime timestamp;

  Message({required this.sender, required this.text, required this.timestamp});

  /// Tworzy obiekt Message z mapy JSON.
  factory Message.fromJson(Map<String, dynamic> json) {
    final czas = json['czas_wyslania'] ?? json['timestamp'] ?? '';
    DateTime parsedTime;
    try {
      parsedTime = DateFormat(
        'EEE, dd MMM yyyy HH:mm:ss',
        'en_US',
      ).parseUtc(czas.replaceAll(' GMT', ''));
    } catch (_) {
      parsedTime = DateTime.now();
    }
    return Message(
      sender: json['sender_email'] ?? json['sender'],
      text: json['tresc'] ?? json['text'],
      timestamp: parsedTime,
    );
  }
}

/// Strona wiadomości
class MessagesPage extends StatefulWidget {
  /// Email aktualnie zalogowanego użytkownika
  final String? currentUserEmail;

  /// Identyfikator wybranej konwersacji
  final int? conversationId;
  const MessagesPage({Key? key, this.currentUserEmail, this.conversationId})
    : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

/// Stan strony wiadomości, obsługuje pobieranie, wysyłanie i usuwanie wiadomości oraz konwersacji.
class _MessagesPageState extends State<MessagesPage> {
  // Lista wiadomości w wybranej konwersacji
  List<Message> _messages = [];
  // Kontroler pola tekstowego do wpisywania wiadomości
  final TextEditingController _controller = TextEditingController();
  // Czy trwa ładowanie danych
  bool _isLoading = false;
  // Lista konwersacji użytkownika
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    // Pobierz wiadomości lub konwersacje przy starcie
    if (widget.conversationId != null) {
      _fetchMessages();
    } else {
      _fetchConversations();
    }
  }

  /// Pobiera wiadomości dla wybranej konwersacji
  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      if (widget.conversationId != null) {
        final response = await http.get(
          Uri.parse(
            '${getApiBaseUrl()}/messages?conversation_id=${widget.conversationId}',
          ),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          setState(() {
            _messages =
                (data['messages'] as List?)
                    ?.map((m) => Message.fromJson(m))
                    .toList() ??
                [];
          });
        }
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  /// Pobiera listę konwersacji użytkownika
  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          '${getApiBaseUrl()}/conversations?user_email=${Uri.encodeComponent(widget.currentUserEmail ?? '')}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          final List<Map<String, dynamic>> allConvs =
              (data['conversations'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
          final Map<String, Map<String, dynamic>> uniqueConvs = {};
          for (final conv in allConvs) {
            final key =
                '${conv['zwierze_id']}_${conv['with'] ?? conv['other_user_email'] ?? ''}';
            uniqueConvs[key] = conv;
          }
          _conversations = uniqueConvs.values.toList();
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  /// Wysyła nową wiadomość w czacie
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || widget.conversationId == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversation_id': widget.conversationId,
          'sender_email': widget.currentUserEmail,
          'text': text,
        }),
      );
      if (response.statusCode == 200) {
        _controller.clear();
        _fetchMessages();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  /// Buduje widok strony (lista konwersacji lub czat)
  @override
  Widget build(BuildContext context) {
    if (widget.conversationId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Wiadomości')),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _conversations.isEmpty
                ? Center(child: Text('Brak historii rozmów.'))
                : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, idx) {
                    final conv = _conversations[idx];
                    final conversationId =
                        conv['conversation_id'] ?? conv['id'];
                    final otherUser =
                        conv['with'] ?? conv['other_user_email'] ?? '';
                    final title = conv['tytul'] ?? '';
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading:
                            conv['zdjecie_url'] != null &&
                                    conv['zdjecie_url'].toString().isNotEmpty
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    conv['zdjecie_url'],
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.pets,
                                          size: 56,
                                          color: Colors.grey,
                                        ),
                                  ),
                                )
                                : Icon(
                                  Icons.pets,
                                  size: 56,
                                  color: Colors.grey,
                                ),
                        title: Text(title.isNotEmpty ? title : 'Brak tytułu'),
                        subtitle: Text('Właściciel: $otherUser'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          tooltip: 'Usuń czat',
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: Text('Usuń czat'),
                                    content: Text(
                                      'Czy na pewno chcesz usunąć tę rozmowę?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: Text('Anuluj'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: Text(
                                          'Usuń',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              // Usuń konwersację
                              final response = await http.delete(
                                Uri.parse(
                                  '${getApiBaseUrl()}/conversations/${conversationId}',
                                ),
                              );
                              if (response.statusCode == 200) {
                                setState(() {
                                  _conversations.removeAt(idx);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Czat usunięty.')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Błąd usuwania czatu.'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => MessagesPage(
                                    currentUserEmail: widget.currentUserEmail,
                                    conversationId: conversationId,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        bottomNavigationBar: BottomAppBar(
          color:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[850]
                  : Colors.white,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.search, color: Color(0xFF42A5F5), size: 32),
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.grey,
                    size: 32,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => FavoritesPage(favorites: const []),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
    // Jeśli jest wybrana konwersacja, wyświetl czat
    return Scaffold(
      appBar: AppBar(
        title: Text('Czat'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      reverse: true,
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) {
                        final msg = _messages[_messages.length - 1 - idx];
                        final isMe = msg.sender == widget.currentUserEmail;
                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isMe ? Color(0xFF42A5F5) : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.text,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'HH:mm, dd.MM.yyyy',
                                  ).format(msg.timestamp.toLocal()),
                                  style: TextStyle(
                                    color:
                                        isMe ? Colors.white70 : Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Napisz wiadomość...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF42A5F5)),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Color(0xFF42A5F5), size: 32),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : Colors.grey,
                  size: 32,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.red, size: 32),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(favorites: const []),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
