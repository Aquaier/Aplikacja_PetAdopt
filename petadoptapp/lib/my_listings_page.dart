// Strona z ogłoszeniami użytkownika (Moje ogłoszenia)
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart' show getApiBaseUrl;
import 'messages_page.dart';
import 'favorites_page.dart';

/// Strona wyświetlająca ogłoszenia dodane przez aktualnie zalogowanego użytkownika.
class MyListingsPage extends StatefulWidget {
  /// Email aktualnie zalogowanego użytkownika
  final String? currentUserEmail;
  const MyListingsPage({Key? key, this.currentUserEmail}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

/// Stan strony MyListingsPage, obsługuje pobieranie i usuwanie ogłoszeń użytkownika.
class _MyListingsPageState extends State<MyListingsPage> {
  // Lista ogłoszeń użytkownika
  List<Map<String, dynamic>> _myAnimals = [];
  // Czy trwa ładowanie danych
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyAnimals();
  }

  /// Pobiera ogłoszenia użytkownika z API
  Future<void> _fetchMyAnimals() async {
    print('MyListingsPage: currentUserEmail = \'${widget.currentUserEmail}\'');
    if (widget.currentUserEmail == null) {
      setState(() {
        _myAnimals = [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final response = await http
          .get(Uri.parse('${getApiBaseUrl()}/animals'))
          .timeout(const Duration(seconds: 10));
      print('Response status: \'${response.statusCode}\'');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['animals'] != null) {
          final animals = List<Map<String, dynamic>>.from(data['animals']);
          setState(() {
            _myAnimals =
                animals
                    .where((a) => a['owner_email'] == widget.currentUserEmail)
                    .toList();
            _loading = false;
          });
        } else {
          setState(() {
            _myAnimals = [];
            _loading = false;
          });
        }
      } else {
        setState(() {
          _myAnimals = [];
          _loading = false;
        });
      }
    } catch (e) {
      print('Error fetching animals: $e');
      setState(() {
        _myAnimals = [];
        _loading = false;
      });
    }
  }

  /// Usuwa ogłoszenie o podanym ID
  void _deleteAnimal(int animalId) async {
    final response = await http.delete(
      Uri.parse(
        '${getApiBaseUrl()}/animals/$animalId?owner_email=${Uri.encodeComponent(widget.currentUserEmail ?? '')}',
      ),
    );
    if (response.statusCode == 200) {
      setState(() {
        _myAnimals.removeWhere((a) => a['id'] == animalId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ogłoszenie usunięte.')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd usuwania ogłoszenia.')));
    }
  }

  /// Buduje widok strony z ogłoszeniami użytkownika
  @override
  Widget build(BuildContext context) {
    if (widget.currentUserEmail == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Moje ogłoszenia')),
        body: Center(
          child: Text('Musisz być zalogowany, aby zobaczyć swoje ogłoszenia.'),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('Moje ogłoszenia')),
      body:
          _loading
              ? Center(child: CircularProgressIndicator())
              : _myAnimals.isEmpty
              ? Center(child: Text('Brak ogłoszeń.'))
              : ListView.builder(
                itemCount: _myAnimals.length,
                itemBuilder: (context, idx) {
                  final animal = _myAnimals[idx];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading:
                          animal['zdjecie_url'] != null &&
                                  animal['zdjecie_url'].toString().isNotEmpty
                              ? Image.network(
                                animal['zdjecie_url'],
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.pets, size: 56),
                              )
                              : Icon(Icons.pets, size: 56),
                      title: Text(animal['tytul'] ?? ''),
                      subtitle: Text(animal['gatunek'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteAnimal(animal['id']),
                          ),
                        ],
                      ),
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
