// Strona edycji ogłoszenia o zwierzęciu.

// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'main.dart' show getApiBaseUrl;

/// Strona umożliwiająca edycję istniejącego ogłoszenia o zwierzęciu.
class EditAnimalPage extends StatefulWidget {
  /// Dane ogłoszenia przekazywane do edycji
  final Map<String, dynamic> animal;

  /// Email aktualnie zalogowanego użytkownika
  final String? currentUserEmail;
  const EditAnimalPage({Key? key, required this.animal, this.currentUserEmail})
    : super(key: key);

  @override
  State<EditAnimalPage> createState() => _EditAnimalPageState();
}

/// Stan strony EditAnimalPage, obsługuje formularz, edycję i usuwanie ogłoszenia.
class _EditAnimalPageState extends State<EditAnimalPage> {
  // Klucz formularza
  final _formKey = GlobalKey<FormState>();
  // Pola formularza
  late String _title, _species, _breed, _desc, _weight, _age;
  // Wybrane zdjęcie (jeśli zmieniono)
  XFile? _imageFile;
  // Czy trwa ładowanie (edycja/usuwanie)
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Inicjalizacja pól formularza danymi ogłoszenia
    _title = widget.animal['tytul'] ?? '';
    _species = widget.animal['gatunek'] ?? '';
    _breed = widget.animal['rasa'] ?? '';
    _desc = widget.animal['opis'] ?? '';
    _weight = widget.animal['waga']?.toString() ?? '';
    _age = widget.animal['wiek']?.toString() ?? '';
  }

  /// Otwiera galerię i pozwala wybrać nowe zdjęcie zwierzaka.
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  /// Usuwa ogłoszenie o zwierzaku
  void _deleteAnimal() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .delete(
            Uri.parse(
              getApiBaseUrl() +
                  '/animals/${widget.animal['id']}?owner_email=${Uri.encodeComponent(widget.currentUserEmail ?? '')}',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ogłoszenie usunięte.')));
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Błąd usuwania ogłoszenia.')));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Błąd sieci: $e')));
    }
  }

  /// Buduje widok strony edycji ogłoszenia.
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edytuj ogłoszenie'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        actions: [
          // Przycisk usuwania ogłoszenia
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _isLoading ? null : _deleteAnimal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Pole do wyboru/zmiany zdjęcia
              GestureDetector(
                onTap: _pickImage,
                child:
                    _imageFile != null
                        ? Image.file(
                          File(_imageFile!.path),
                          height: 180,
                          fit: BoxFit.cover,
                        )
                        : (widget.animal['zdjecie_url'] != null &&
                                widget.animal['zdjecie_url']
                                    .toString()
                                    .isNotEmpty
                            ? Image.network(
                              widget.animal['zdjecie_url'],
                              height: 180,
                              fit: BoxFit.cover,
                            )
                            : Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.add_a_photo, size: 60),
                              ),
                            )),
              ),
              const SizedBox(height: 16),
              // Pole tytułu ogłoszenia
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Tytuł ogłoszenia',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Wpisz tytuł' : null,
                onSaved: (v) => _title = v ?? '',
              ),
              const SizedBox(height: 12),
              // Pole gatunku
              TextFormField(
                initialValue: _species,
                decoration: const InputDecoration(
                  labelText: 'Gatunek (pies/kot)',
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Wpisz gatunek' : null,
                onSaved: (v) => _species = v ?? '',
              ),
              const SizedBox(height: 12),
              // Pole rasy
              TextFormField(
                initialValue: _breed,
                decoration: const InputDecoration(labelText: 'Rasa'),
                onSaved: (v) => _breed = v ?? '',
              ),
              const SizedBox(height: 12),
              // Pole wieku
              TextFormField(
                initialValue: _age,
                decoration: const InputDecoration(labelText: 'Wiek'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _age = v ?? '',
              ),
              const SizedBox(height: 12),
              // Pole wagi
              TextFormField(
                initialValue: _weight,
                decoration: const InputDecoration(labelText: 'Waga'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _weight = v ?? '',
              ),
              const SizedBox(height: 12),
              // Pole opisu
              TextFormField(
                initialValue: _desc,
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
                onSaved: (v) => _desc = v ?? '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
