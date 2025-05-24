import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'messages_page.dart';
import 'favorites_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  const HomePage({super.key, this.setDarkMode, this.darkMode = false});

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
  bool _isDragging = false;
  Size _screenSize = Size.zero;
  List<Map<String, dynamic>> _animals = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenSize = MediaQuery.of(context).size;
      _fetchAnimalsAndPrecacheImages(context);
    });
  }

  Future<void> _fetchAnimalsAndPrecacheImages(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.104:5000/animals'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['animals'] != null) {
          final animals = List<Map<String, dynamic>>.from(data['animals']);
          print('Animals fetched: $animals'); // Debugowanie
          animals.shuffle(Random());
          setState(() {
            _animals = animals;
          });
          // Precache all images
          for (final animal in animals) {
            final url = animal['zdjecie_url'];
            if (url != null && url.toString().isNotEmpty) {
              // cached_network_image: prefetch
              CachedNetworkImageProvider(
                url,
              ).resolve(const ImageConfiguration());
            }
          }
        } else {
          setState(() {
            _animals = [];
          });
        }
      } else {
        setState(() {
          _animals = [];
        });
      }
    } catch (e) {
      print('Error fetching animals: $e'); // Debugowanie
      setState(() {
        _animals = [];
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
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;

    final newPosition = details.globalPosition;
    _dragPosition = Offset(
      newPosition.dx - _dragStart!.dx,
      newPosition.dy - _dragStart!.dy,
    );

    // Oblicz kąt na podstawie pozycji X
    final angle = _dragPosition.dx / _screenSize.width * 0.5;
    setState(() => _angle = angle);
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = _dragPosition;
    final isDraggedFarEnough = dragVector.dx.abs() > _screenSize.width * 0.4;

    if (isDraggedFarEnough) {
      final isSwipedRight = dragVector.dx > 0;

      if (isSwipedRight && _favorites.isNotEmpty) {
        _favorites.add(_favorites[0]);
      }

      setState(() {
        if (_favorites.isNotEmpty) {
          final first = _favorites.removeAt(0);
          _favorites.add(first);
        }
      });
    }

    setState(() {
      _dragPosition = Offset.zero;
      _dragStart = null;
      _angle = 0;
      _isDragging = false;
    });
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
              // Górny pasek z napisem i przyciskiem ustawień
              Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'PetAdopt',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.darkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
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
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    _animals.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : PageView.builder(
                          controller: _pageController,
                          itemCount: _animals.length,
                          itemBuilder: (context, index) {
                            final animal = _animals[index];
                            return GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Transform(
                                transform:
                                    Matrix4.identity()
                                      ..translate(
                                        _dragPosition.dx,
                                        _dragPosition.dy,
                                      )
                                      ..rotateZ(_angle),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                  elevation: 8,
                                  margin: EdgeInsets.all(24),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(32),
                                    child: Stack(
                                      children: [
                                        if (animal['zdjecie_url'] != null &&
                                            animal['zdjecie_url']
                                                .toString()
                                                .isNotEmpty)
                                          Positioned.fill(
                                            child: Builder(
                                              builder: (context) {
                                                print(
                                                  'Animal image URL: ${animal['zdjecie_url']}',
                                                ); // Debugowanie
                                                return CachedNetworkImage(
                                                  imageUrl:
                                                      animal['zdjecie_url'],
                                                  fit: BoxFit.cover,
                                                  placeholder:
                                                      (context, url) => Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 100,
                                                          color:
                                                              Colors.grey[400],
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
                                                child: Icon(
                                                  Icons.pets,
                                                  size: 100,
                                                  color: Colors.grey[400],
                                                ),
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
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      32,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(32),
                                                  ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  animal['tytul'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
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
                                ),
                              ),
                            );
                          },
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
