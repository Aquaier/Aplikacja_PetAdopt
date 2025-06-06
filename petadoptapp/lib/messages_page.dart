import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  final String? currentUserEmail;
  final String? chatWithEmail; // If provided, open chat with this user
  const MessagesPage({super.key, this.currentUserEmail, this.chatWithEmail});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  // Simulated message storage: { 'user1|user2': [ {from, to, text, time}, ... ] }
  static final Map<String, List<Map<String, dynamic>>> _conversations = {};
  String? _selectedUser;
  final TextEditingController _messageController = TextEditingController();

  List<String> get _allUsers {
    // In real app, fetch from backend
    final users = <String>{};
    _conversations.forEach((key, msgs) {
      final parts = key.split('|');
      users.addAll(parts);
    });
    if (widget.currentUserEmail != null) users.remove(widget.currentUserEmail);
    return users.toList();
  }

  String _chatKey(String user1, String user2) {
    final sorted = [user1, user2]..sort();
    return '${sorted[0]}|${sorted[1]}';
  }

  List<Map<String, dynamic>> get _messages {
    if (widget.currentUserEmail == null || _selectedUser == null) return [];
    return _conversations[_chatKey(widget.currentUserEmail!, _selectedUser!)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    if (widget.chatWithEmail != null) {
      _selectedUser = widget.chatWithEmail;
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || widget.currentUserEmail == null || _selectedUser == null) return;
    final key = _chatKey(widget.currentUserEmail!, _selectedUser!);
    _conversations.putIfAbsent(key, () => []);
    _conversations[key]!.add({
      'from': widget.currentUserEmail!,
      'to': _selectedUser!,
      'text': text,
      'time': DateTime.now(),
    });
    _messageController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Wiadomości',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        leading: widget.currentUserEmail != null && _selectedUser != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
                onPressed: () => setState(() => _selectedUser = null),
              )
            : null,
      ),
      body: widget.currentUserEmail == null
          ? Center(child: Text('Zaloguj się, aby korzystać z wiadomości'))
          : _selectedUser == null
              ? _buildUserList()
              : _buildChat(),
      bottomNavigationBar: BottomAppBar(
        color: isDark ? Colors.grey[850] : Colors.white,
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
                icon: Icon(Icons.chat_bubble_outline, color: isDark ? Colors.white70 : Colors.grey, size: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.red, size: 32),
                onPressed: () {
                  Navigator.of(context).pushNamed('/favorites');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList() {
    final users = _allUsers;
    if (users.isEmpty) {
      return Center(child: Text('Brak rozmów. Zacznij nową rozmowę!'));
    }
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, idx) {
        final user = users[idx];
        return ListTile(
          title: Text(user),
          onTap: () => setState(() => _selectedUser = user),
        );
      },
    );
  }

  Widget _buildChat() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, idx) {
              final msg = _messages[_messages.length - 1 - idx];
              final isMe = msg['from'] == widget.currentUserEmail;
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe ? Color(0xFF42A5F5) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    msg['text'],
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Napisz wiadomość...',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send, color: Color(0xFF42A5F5)),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
