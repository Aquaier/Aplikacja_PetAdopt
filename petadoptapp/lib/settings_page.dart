// Strona ustawień aplikacji (Ustawienia konta, motyw, powiadomienia, wylogowanie, usuwanie konta)
// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'main.dart' show getApiBaseUrl;
import 'messages_page.dart';
import 'favorites_page.dart';
import 'my_listings_page.dart';

/// Strona ustawień aplikacji.
class SettingsPage extends StatefulWidget {
  /// Funkcja do ustawiania trybu ciemnego
  final void Function(bool)? setDarkMode;

  /// Czy tryb ciemny jest aktywny
  final bool darkMode;

  /// Email aktualnie zalogowanego użytkownika
  final String? currentUserEmail;
  const SettingsPage({
    super.key,
    this.setDarkMode,
    this.darkMode = false,
    this.currentUserEmail,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// Stan strony SettingsPage, obsługuje ustawienia konta, motyw, powiadomienia i akcje użytkownika.
class _SettingsPageState extends State<SettingsPage> {
  // Czy powiadomienia są włączone
  bool notificationsEnabled = true;
  // Czy tryb ciemny jest aktywny
  late bool darkMode;

  @override
  void initState() {
    super.initState();
    darkMode = widget.darkMode;
  }

  /// Buduje widok strony ustawień
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        title: Text(
          'Ustawienia',
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 32,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
            child: Text(
              'KONTO',
              style: TextStyle(
                color: darkMode ? Colors.white70 : Colors.black45,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: darkMode ? Colors.grey[850] : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.notifications_none,
                    color: darkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    'Powiadomienia',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: notificationsEnabled,
                    activeColor: Color(0xFF42A5F5),
                    onChanged: (v) => setState(() => notificationsEnabled = v),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.dark_mode,
                    color: darkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    'Tryb ciemny',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Switch(
                    value: darkMode,
                    activeColor: Color(0xFF42A5F5),
                    onChanged: (v) {
                      setState(() => darkMode = v);
                      if (widget.setDarkMode != null) widget.setDarkMode!(v);
                    },
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(
                    Icons.list_alt,
                    color: darkMode ? Colors.white70 : Colors.black54,
                  ),
                  title: Text(
                    'Moje ogłoszenia',
                    style: TextStyle(
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: darkMode ? Colors.white38 : Colors.black38,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => MyListingsPage(
                              currentUserEmail: widget.currentUserEmail,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF42A5F5),
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  child: Text(
                    'Wyloguj',
                    style: TextStyle(color: Color(0xFF42A5F5)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    int confirmCount = 0;
                    final messages = [
                      'Czy na pewno chcesz usunąć konto? 😢',
                      'Jesteś pewien, że chcesz usunąć swoje konto? 😢😢',
                      'To będzie nieodwracalne... Czy na pewno? 😢😢😢',
                      'Naprawdę chcesz odejść? Prosimy, przemyśl to... 😢😢😢😢',
                      'Ostatnia szansa! Usunąć konto? 😭😭😭😭😭',
                    ];
                    bool confirmed = false;
                    while (confirmCount < 5) {
                      confirmed =
                          await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text('Potwierdzenie'),
                                  content: Text(messages[confirmCount]),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
                                      child: Text('Anuluj'),
                                    ),
                                    TextButton(
                                      onPressed:
                                          () => Navigator.of(context).pop(true),
                                      child: Text('Tak'),
                                    ),
                                  ],
                                ),
                          ) ??
                          false;
                      if (!confirmed) break;
                      confirmCount++;
                    }
                    if (confirmed && confirmCount == 5) {
                      final email = widget.currentUserEmail;
                      if (email != null) {
                        final response = await http.delete(
                          Uri.parse(
                            getApiBaseUrl() +
                                '/delete-user?email=' +
                                Uri.encodeComponent(email),
                          ),
                        );
                        if (response.statusCode == 200) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Konto i ogłoszenia zostały usunięte.',
                              ),
                            ),
                          );
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Błąd usuwania konta.')),
                          );
                        }
                      }
                    }
                  },
                  child: Text(
                    'Usuń konto',
                    style: TextStyle(
                      color: darkMode ? Colors.white70 : Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(children: [
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: darkMode ? Colors.grey[850] : Colors.white,
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
                  color: darkMode ? Colors.white70 : Colors.grey,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => MessagesPage(
                            currentUserEmail: widget.currentUserEmail,
                          ),
                    ),
                  );
                },
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
