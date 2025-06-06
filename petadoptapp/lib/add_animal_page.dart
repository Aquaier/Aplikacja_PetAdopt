import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddAnimalPage extends StatefulWidget {
  final String? currentUserEmail;
  const AddAnimalPage({super.key, this.currentUserEmail});

  @override
  State<AddAnimalPage> createState() => _AddAnimalPageState();
}

class _AddAnimalPageState extends State<AddAnimalPage> {
  final _formKey = GlobalKey<FormState>();
  String? _title, _species, _breed, _desc, _weight, _age;
  XFile? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) return;
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    try {
      var uri = Uri.parse('http://192.168.1.172:5000/animals');
      var request = http.MultipartRequest('POST', uri);
      request.fields['tytul'] = _title ?? '';
      request.fields['gatunek'] = _species ?? '';
      request.fields['rasa'] = _breed ?? '';
      request.fields['wiek'] = _age ?? '';
      request.fields['waga'] = _weight ?? '';
      request.fields['opis'] = _desc ?? '';
      request.fields['owner_email'] = widget.currentUserEmail ?? '';
      request.fields['imie'] = '';
      request.files.add(await http.MultipartFile.fromPath('zdjecie', _imageFile!.path));
      var response = await request.send();
      if (response.statusCode == 200) {
        // Sukces
        setState(() => _isLoading = false);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd dodawania zwierzaka!')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd sieci: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj zwierzaka'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageFile == null
                    ? Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.add_a_photo, size: 60)),
                      )
                    : Image.file(File(_imageFile!.path), height: 180, fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Tytuł ogłoszenia'),
                validator: (v) => v == null || v.isEmpty ? 'Wpisz tytuł' : null,
                onSaved: (v) => _title = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Gatunek (pies/kot)'),
                validator: (v) => v == null || v.isEmpty ? 'Wpisz gatunek' : null,
                onSaved: (v) => _species = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Rasa'),
                onSaved: (v) => _breed = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Wiek'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _age = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Waga'),
                keyboardType: TextInputType.number,
                onSaved: (v) => _weight = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Opis'),
                maxLines: 3,
                onSaved: (v) => _desc = v,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Dodaj', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
