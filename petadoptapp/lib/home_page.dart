import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'messages_page.dart';
import 'favorites_page.dart';
import 'add_animal_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  final String? currentUserEmail;
  const HomePage({
    super.key,
    this.setDarkMode,
    this.darkMode = false,
    this.currentUserEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final List<String> _favorites = [];
  String? _filterType;
  String? _filterBreed;
  RangeValues? _filterAgeRange;

  // Zmienne do obsługi gestów
  Offset? _dragStart;
  Offset _dragPosition = Offset.zero;
  double _angle = 0;
  Size _screenSize = Size.zero;
  List<Map<String, dynamic>> _animals = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenSize = MediaQuery.of(context).size;
      _fetchAnimals(context);
    });
  }

  Future<void> _fetchAnimals(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.109:5000/animals'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['animals'] != null) {
          final animals = List<Map<String, dynamic>>.from(data['animals']);
          animals.shuffle(Random());
          setState(() {
            _animals = animals;
            // Reset przesuwania po wczytaniu nowych zwierząt lub filtrów
            _dragPosition = Offset.zero;
            _dragStart = null;
            _angle = 0;
          });
        } else {
          setState(() {
            _animals = [];
            _dragPosition = Offset.zero;
            _dragStart = null;
            _angle = 0;
          });
        }
      } else {
        setState(() {
          _animals = [];
          _dragPosition = Offset.zero;
          _dragStart = null;
          _angle = 0;
        });
      }
    } catch (e) {
      setState(() {
        _animals = [];
        _dragPosition = Offset.zero;
        _dragStart = null;
        _angle = 0;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    _dragStart = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;

    final newPosition = details.globalPosition;
    _dragPosition = Offset(
      newPosition.dx - _dragStart!.dx,
      newPosition.dy - _dragStart!.dy,
    );

    // Zmniejsz czułość kąta, aby przesuwanie było bardziej naturalne
    final angle = _dragPosition.dx / (_screenSize.width * 1.2) * 0.5;
    setState(() => _angle = angle);
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = _dragPosition;
    // Zmniejsz próg przesunięcia, aby swipe był bardziej responsywny
    final isDraggedFarEnough = dragVector.dx.abs() > _screenSize.width * 0.25;

    if (isDraggedFarEnough) {
      final isSwipedRight = dragVector.dx > 0;

      setState(() {
        if (isSwipedRight) {
          final swipedAnimal = _animals.removeAt(0);
          _favorites.add(swipedAnimal['tytul']);
        } else {
          final rejectedAnimal = _animals.removeAt(0);
          _animals.add(rejectedAnimal);
        }

        // Trigger UI update
        _animals = List.from(_animals);
      });
    }

    setState(() {
      _dragPosition = Offset.zero;
      _dragStart = null;
      _angle = 0;
    });
  }

  void _showAnimalDetails(Map<String, dynamic> animal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child:
                          animal['zdjecie_url'] != null &&
                                  animal['zdjecie_url'].toString().isNotEmpty
                              ? CachedNetworkImage(
                                imageUrl: animal['zdjecie_url'],
                                fit: BoxFit.cover,
                                height: 220,
                                width: double.infinity,
                                placeholder:
                                    (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) => Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 100,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                              )
                              : Container(
                                height: 220,
                                color: Colors.grey[200],
                                child: Center(
                                  child: Icon(
                                    Icons.pets,
                                    size: 100,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      animal['tytul'] ?? '',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // czarny tytuł
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (animal['wiek'] != null)
                      Text(
                        'Wiek: ${animal['wiek']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ), // czarny
                      ),
                    if (animal['waga'] != null)
                      Text(
                        'Waga: ${animal['waga']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                        ), // czarny
                      ),
                    const SizedBox(height: 16),
                    if (animal['opis'] != null)
                      Text(
                        animal['opis'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ), // czarny
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            // Przekieruj do MessagesPage z ownerem ogłoszenia
                            if (animal['owner_email'] != null &&
                                animal['owner_email'] != '') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (context) => MessagesPage(
                                        currentUserEmail:
                                            widget.currentUserEmail,
                                        chatWithEmail: animal['owner_email'],
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Brak adresu e-mail właściciela ogłoszenia.',
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.message, color: Colors.white),
                          label: const Text(
                            'Napisz',
                            style: TextStyle(
                              color: Colors.white,
                            ), // biały tekst
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF42A5F5), // niebieski
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone,
                            color: Color(0xFF42A5F5), // niebieski
                          ),
                          label: const Text(
                            'Zadzwoń',
                            style: TextStyle(color: Color(0xFF42A5F5)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF42A5F5),
                            ), // niebieski
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Color(0xFF42A5F5), // niebieski
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAnimalCard(Map<String, dynamic> animal, {bool isTop = false}) {
    if (isTop) {
      return GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pageController]),
          builder: (context, child) {
            return Transform(
              transform:
                  Matrix4.identity()
                    ..translate(_dragPosition.dx, _dragPosition.dy)
                    ..rotateZ(_angle),
              child: child,
            );
          },
          child: _animalCardContent(animal),
        ),
      );
    } else {
      return _animalCardContent(animal);
    }
  }

  Widget _animalCardContent(Map<String, dynamic> animal) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      margin: EdgeInsets.all(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            if (animal['zdjecie_url'] != null &&
                animal['zdjecie_url'].toString().isNotEmpty)
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    return CachedNetworkImage(
                      imageUrl: animal['zdjecie_url'],
                      fit: BoxFit.cover,
                      placeholder:
                          (context, url) =>
                              Center(child: CircularProgressIndicator()),
                      errorWidget:
                          (context, url, error) => Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                          ),
                    );
                  },
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.pets, size: 100, color: Colors.grey[400]),
                  ),
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            animal['tytul'] ?? '',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _showAnimalDetails(animal);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      animal['opis'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredAnimals() {
    return _animals.where((animal) {
      // Typ zwierzęcia
      if (_filterType != null && _filterType != 'Oba') {
        final typ = (animal['gatunek'] ?? '').toString().toLowerCase();
        if ((_filterType == 'Pies' && typ != 'pies') ||
            (_filterType == 'Kot' && typ != 'kot')) {
          return false;
        }
      }
      // Rasa
      if (_filterBreed != null && _filterBreed!.trim().isNotEmpty) {
        final breed = (animal['rasa'] ?? '').toString().toLowerCase();
        if (!breed.contains(_filterBreed!.trim().toLowerCase())) {
          return false;
        }
      }
      // Wiek
      if (_filterAgeRange != null) {
        final wiek = int.tryParse((animal['wiek'] ?? '').toString());
        if (wiek == null ||
            wiek < _filterAgeRange!.start ||
            wiek > _filterAgeRange!.end) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.darkMode ? Colors.grey[900] : Colors.grey[100],
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 32),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _filteredAnimals().isEmpty
                        ? Center(
                          child: Text(
                            'Brak zwierząt do przeglądania',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color:
                                  widget.darkMode
                                      ? Colors.white70
                                      : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : Stack(
                          children: [
                            for (
                              int i = _filteredAnimals().length - 1;
                              i >= 0;
                              i--
                            )
                              _buildAnimalCard(
                                _filteredAnimals()[i],
                                isTop: i == 0,
                              ),
                          ],
                        ),
              ),
            ],
          ),
          // Przycisk filtrów w lewym górnym rogu
          Positioned(
            top: 24,
            left: 16,
            child: IconButton(
              icon: Icon(
                Icons.filter_list,
                color: widget.darkMode ? Colors.white : Colors.black,
                size: 32,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String selectedType = _filterType ?? 'Oba';
                    String breed = _filterBreed ?? '';
                    RangeValues ageRange =
                        _filterAgeRange ?? const RangeValues(0, 20);
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          backgroundColor:
                              widget.darkMode ? Colors.grey[900] : Colors.white,
                          title: Center(
                            child: Text(
                              'Filtry',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Typ zwierzęcia',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: Text('Pies'),
                                      selected: selectedType == 'Pies',
                                      onSelected:
                                          (v) => setState(
                                            () => selectedType = 'Pies',
                                          ),
                                    ),
                                    SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Kot'),
                                      selected: selectedType == 'Kot',
                                      onSelected:
                                          (v) => setState(
                                            () => selectedType = 'Kot',
                                          ),
                                    ),
                                    SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Oba'),
                                      selected: selectedType == 'Oba',
                                      onSelected:
                                          (v) => setState(
                                            () => selectedType = 'Oba',
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Rasa',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Podaj rasę',
                                  ),
                                  controller: TextEditingController(
                                    text: breed,
                                  ),
                                  onChanged: (v) => breed = v,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Wiek',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                RangeSlider(
                                  values: ageRange,
                                  min: 0,
                                  max: 20,
                                  divisions: 20,
                                  labels: RangeLabels(
                                    ageRange.start.round().toString(),
                                    ageRange.end.round().toString(),
                                  ),
                                  onChanged:
                                      (v) => setState(() => ageRange = v),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Od: ${ageRange.start.round()} lat'),
                                    Text('Do: ${ageRange.end.round()} lat'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Anuluj'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF42A5F5),
                                foregroundColor:
                                    Colors.white, // zapewnia biały tekst
                              ),
                              onPressed: () {
                                setState(() {
                                  _filterType = selectedType;
                                  _filterBreed = breed;
                                  _filterAgeRange = ageRange;
                                  // Reset przesuwania po zmianie filtrów
                                  _dragPosition = Offset.zero;
                                  _dragStart = null;
                                  _angle = 0;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Gotowe',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Stack(
            children: [
              // Pasek górny bez napisu/logo
              SizedBox(height: 56),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: widget.darkMode ? Colors.white : Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => SettingsPage(
                                    setDarkMode: widget.setDarkMode,
                                    darkMode: widget.darkMode,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: widget.darkMode ? Colors.white : Colors.black,
                          size: 30,
                        ),
                        tooltip: 'Dodaj zwierzaka',
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (context) => AddAnimalPage(
                                    currentUserEmail: widget.currentUserEmail,
                                  ),
                            ),
                          );
                          if (result == true) {
                            _fetchAnimals(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: widget.darkMode ? Colors.grey[850] : Colors.white,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.search, color: Color(0xFF42A5F5), size: 32),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: widget.darkMode ? Colors.white70 : Colors.grey,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MessagesPage(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.red, size: 32),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => FavoritesPage(favorites: _favorites),
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
