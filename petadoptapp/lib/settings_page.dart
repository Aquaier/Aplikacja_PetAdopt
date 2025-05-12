import 'package:flutter/material.dart';
import 'messages_page.dart';
import 'favorites_page.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  const SettingsPage({super.key, this.setDarkMode, this.darkMode = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  late bool darkMode;

  @override
  void initState() {
    super.initState();
    darkMode = widget.darkMode;
  }

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
            fontSize: 32, // dopasowana do reszty
            fontFamily: 'Poppins', // spójna czcionka
          ),
        ),
        centerTitle: true, // wyśrodkowanie
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 8),
            child: Text('KONTO', style: TextStyle(color: darkMode ? Colors.white70 : Colors.black45, fontWeight: FontWeight.bold, letterSpacing: 1)),
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
                  leading: Icon(Icons.notifications_none, color: darkMode ? Colors.white70 : Colors.black54),
                  title: Text('Powiadomienia', style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
                  trailing: Switch(
                    value: notificationsEnabled,
                    activeColor: Color(0xFF42A5F5),
                    onChanged: (v) => setState(() => notificationsEnabled = v),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.dark_mode, color: darkMode ? Colors.white70 : Colors.black54),
                  title: Text('Tryb ciemny', style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
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
                  leading: Icon(Icons.person_outline, color: darkMode ? Colors.white70 : Colors.black54),
                  title: Text('Edytuj profil', style: TextStyle(color: darkMode ? Colors.white : Colors.black)),
                  trailing: Icon(Icons.chevron_right, color: darkMode ? Colors.white38 : Colors.black38),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EditProfilePage()),
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
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF42A5F5),
                    textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkMode ? Colors.white : Colors.black),
                  ),
                  child: Text('Wyloguj', style: TextStyle(color: Color(0xFF42A5F5))),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Usuń konto', style: TextStyle(color: darkMode ? Colors.white70 : Colors.black54, decoration: TextDecoration.underline)),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                // Usunięto ikony Facebooka i aparatu
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
                icon: Icon(Icons.chat_bubble_outline, color: darkMode ? Colors.white70 : Colors.grey, size: 32),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MessagesPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.red, size: 32),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FavoritesPage(favorites: const []), // Placeholder, bo lista polubionych jest w HomePage
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
