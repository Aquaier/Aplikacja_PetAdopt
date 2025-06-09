import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'main.dart' show getApiBaseUrl;

class MyListingsPage extends StatefulWidget {
  final String? currentUserEmail;
  const MyListingsPage({Key? key, this.currentUserEmail}) : super(key: key);

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<Map<String, dynamic>> _myAnimals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyAnimals();
  }

  Future<void> _fetchMyAnimals() async {
    print(
      'MyListingsPage: currentUserEmail = \'${widget.currentUserEmail}\'',
    ); // Debug print
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
          .timeout(const Duration(seconds: 10)); // Added timeout
      print('Response status: \'${response.statusCode}\''); // Debug print
      print('Response body: ${response.body}'); // Debug print
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
      print('Error fetching animals: $e'); // Debug print
      setState(() {
        _myAnimals = [];
        _loading = false;
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
