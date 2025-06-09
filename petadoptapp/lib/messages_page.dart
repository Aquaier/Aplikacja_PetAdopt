import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'main.dart' show getApiBaseUrl;

class Message {
  final String sender;
  final String text;
  final DateTime timestamp;

  Message({required this.sender, required this.text, required this.timestamp});

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

class MessagesPage extends StatefulWidget {
  final String? currentUserEmail;
  final String? chatWithEmail;
  final int? animalId;
  const MessagesPage({
    Key? key,
    this.currentUserEmail,
    this.chatWithEmail,
    this.animalId,
  }) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<Message> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    if (widget.chatWithEmail != null) {
      _fetchMessages();
    } else {
      _fetchConversations();
    }
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          getApiBaseUrl() +
              '/messages?user1=${Uri.encodeComponent(widget.currentUserEmail ?? '')}&user2=${Uri.encodeComponent(widget.chatWithEmail ?? '')}&animal_id=${widget.animalId ?? ''}',
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
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
          getApiBaseUrl() +
              '/conversations?user=${Uri.encodeComponent(widget.currentUserEmail ?? '')}',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _conversations =
              (data['conversations'] as List?)?.cast<Map<String, dynamic>>() ??
              [];
        });
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(getApiBaseUrl() + '/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_email': widget.currentUserEmail,
          'receiver_email': widget.chatWithEmail,
          'animal_id': widget.animalId,
          'tresc': text,
        }),
      );
      if (response.statusCode == 200) {
        _controller.clear();
        _fetchMessages();
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatWithEmail == null) {
      // Show conversation list (inbox)
      return Scaffold(
        appBar: AppBar(title: Text('Wiadomości')),
        body:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                  itemCount: _conversations.length,
                  itemBuilder: (context, idx) {
                    final conv = _conversations[idx];
                    final otherUser = conv['other_user_email'] ?? '';
                    final animalId = conv['animal_id'];
                    final lastMsg = conv['last_message'] ?? '';
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text(otherUser),
                      subtitle: Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => MessagesPage(
                                  currentUserEmail: widget.currentUserEmail,
                                  chatWithEmail: otherUser,
                                  animalId: animalId,
                                ),
                          ),
                        );
                      },
                    );
                  },
                ),
      );
    }
    // Show chat with selected user
    return Scaffold(
      appBar: AppBar(
        title: Text('Czat z ${widget.chatWithEmail ?? ''}'),
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
    );
  }
}
