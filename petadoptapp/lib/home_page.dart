import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'messages_page.dart';
import 'favorites_page.dart';

class HomePage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  const HomePage({super.key, this.setDarkMode, this.darkMode = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  final List<String> _cardContents = [
    'dac zdjecia',
    'dac zdjecia',
    'dac zdjecia',
  ];
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _screenSize = MediaQuery.of(context).size;
    });
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
      
      if (isSwipedRight && _cardContents.isNotEmpty) {
        _favorites.add(_cardContents[0]);
      }
      
      setState(() {
        if (_cardContents.isNotEmpty) {
          final first = _cardContents.removeAt(0);
          _cardContents.add(first);
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
                  const SizedBox(width: 32), // Dodaj odstęp z lewej
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'PetAdopt',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.darkMode ? Colors.white : Colors.black,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: widget.darkMode ? Colors.white : Colors.grey, size: 32),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsPage(
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
                child: Center(
                  child: SizedBox(
                    width: 340,
                    height: 480,
                    child: Stack(
                      children: [
                        for (int i = _cardContents.length - 1; i >= 0; i--)
                          if (i == 0)
                            // Pierwsza karta - swipe
                            GestureDetector(
                              onPanStart: _onPanStart,
                              onPanUpdate: _onPanUpdate,
                              onPanEnd: _onPanEnd,
                              child: Transform(
                                transform: Matrix4.identity()
                                  ..translate(_dragPosition.dx, _dragPosition.dy)
                                  ..rotateZ(_angle),
                                child: Stack(
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                      elevation: 8,
                                      margin: EdgeInsets.zero,
                                      child: Center(
                                        child: Text(
                                          _cardContents[0],
                                          style: const TextStyle(fontSize: 22, color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    if (_isDragging)
                                      Positioned(
                                        right: _dragPosition.dx < 0 ? 20 : null,
                                        left: _dragPosition.dx > 0 ? 20 : null,
                                        top: 20,
                                        child: Transform.rotate(
                                          angle: _dragPosition.dx < 0 ? -0.5 : 0.5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: _dragPosition.dx < 0 ? Colors.red : Colors.green,
                                                width: 3,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _dragPosition.dx < 0 ? 'NOPE' : 'LIKE',
                                              style: TextStyle(
                                                color: _dragPosition.dx < 0 ? Colors.red : Colors.green,
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // Karty pod spodem - efekt stosu
                            AnimatedBuilder(
                              animation: Listenable.merge([ValueNotifier(_dragPosition.dx), ValueNotifier(_isDragging)]),
                              builder: (context, child) {
                                // Im bliżej przesunięcia, tym bardziej podnosi się karta pod spodem
                                double offsetY = 24.0 * i - (_isDragging && i == 1 ? _dragPosition.dx.abs() * 0.08 : 0);
                                double scale = 1.0 - (0.03 * i) + (_isDragging && i == 1 ? (_dragPosition.dx.abs() / 1000) : 0);
                                return Transform(
                                  transform: Matrix4.identity()
                                    ..translate(0.0, offsetY)
                                    ..scale(scale),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    elevation: 4,
                                    color: Colors.grey[200],
                                    margin: EdgeInsets.zero,
                                    child: Center(
                                      child: Text(
                                        _cardContents[i],
                                        style: const TextStyle(fontSize: 22, color: Colors.black26),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Przycisk filtrów w lewym górnym rogu
          Positioned(
            top: 24,
            left: 16,
            child: IconButton(
              icon: Icon(Icons.filter_list, color: widget.darkMode ? Colors.white : Colors.black, size: 32),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    String selectedType = _filterType ?? 'Oba';
                    String breed = _filterBreed ?? '';
                    RangeValues ageRange = _filterAgeRange ?? const RangeValues(0, 20);
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          backgroundColor: widget.darkMode ? Colors.grey[900] : Colors.white,
                          title: Center(
                            child: Text(
                              'Filtry',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Typ zwierzęcia', style: TextStyle(fontWeight: FontWeight.w500)),
                                Row(
                                  children: [
                                    ChoiceChip(
                                      label: Text('Pies'),
                                      selected: selectedType == 'Pies',
                                      onSelected: (v) => setState(() => selectedType = 'Pies'),
                                    ),
                                    SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Kot'),
                                      selected: selectedType == 'Kot',
                                      onSelected: (v) => setState(() => selectedType = 'Kot'),
                                    ),
                                    SizedBox(width: 8),
                                    ChoiceChip(
                                      label: Text('Oba'),
                                      selected: selectedType == 'Oba',
                                      onSelected: (v) => setState(() => selectedType = 'Oba'),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text('Rasa', style: TextStyle(fontWeight: FontWeight.w500)),
                                TextField(
                                  decoration: InputDecoration(hintText: 'Podaj rasę'),
                                  controller: TextEditingController(text: breed),
                                  onChanged: (v) => breed = v,
                                ),
                                SizedBox(height: 16),
                                Text('Wiek', style: TextStyle(fontWeight: FontWeight.w500)),
                                RangeSlider(
                                  values: ageRange,
                                  min: 0,
                                  max: 20,
                                  divisions: 20,
                                  labels: RangeLabels(
                                    ageRange.start.round().toString(),
                                    ageRange.end.round().toString(),
                                  ),
                                  onChanged: (v) => setState(() => ageRange = v),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                foregroundColor: Colors.white, // zapewnia biały tekst
                              ),
                              onPressed: () {
                                setState(() {
                                  _filterType = selectedType;
                                  _filterBreed = breed;
                                  _filterAgeRange = ageRange;
                                });
                                Navigator.of(context).pop();
                              },
                              child: Text('Gotowe', style: TextStyle(color: Colors.white)),
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
                icon: Icon(Icons.chat_bubble_outline, color: widget.darkMode ? Colors.white70 : Colors.grey, size: 32),
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
                      builder: (context) => FavoritesPage(favorites: _favorites),
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
