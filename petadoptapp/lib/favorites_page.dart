import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  final List<String> favorites;
  final List<Map<String, dynamic>>? allAnimals;
  final void Function(
    BuildContext,
    Map<String, dynamic>, {
    String? currentUserEmail,
  })?
  onShowDetails;
  final String? currentUserEmail;
  const FavoritesPage({
    super.key,
    required this.favorites,
    this.allAnimals,
    this.onShowDetails,
    this.currentUserEmail,
  });

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
          'Polubione',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      body:
          favorites.isEmpty
              ? Center(
                child: Text(
                  'Brak polubionych elementów',
                  style: TextStyle(
                    fontSize: 20,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final title = favorites[index];
                  final animal = allAnimals?.firstWhere(
                    (a) => a['tytul'] == title,
                    orElse: () => {},
                  );
                  return Card(
                    color: isDark ? Colors.grey[850] : Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 18,
                        ),
                      ),
                      onTap:
                          animal != null &&
                                  animal.isNotEmpty &&
                                  onShowDetails != null
                              ? () => onShowDetails!(
                                context,
                                animal,
                                currentUserEmail: currentUserEmail,
                              )
                              : null,
                    ),
                  );
                },
              ),
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
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: isDark ? Colors.white70 : Colors.grey,
                  size: 32,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/messages');
                },
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.red, size: 32),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
