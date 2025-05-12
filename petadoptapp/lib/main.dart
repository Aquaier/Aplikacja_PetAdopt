import 'package:flutter/material.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'favorites_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool darkMode = false;

  void setDarkMode(bool value) {
    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logowanie',
      theme: ThemeData.light().copyWith(
        colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: Color(0xFF42A5F5), // jasny niebieski
          secondary: Color(0xFF42A5F5),
        ),
        primaryColor: Color(0xFF42A5F5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF42A5F5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF42A5F5),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xFF42A5F5)),
          trackColor: MaterialStateProperty.all(Color(0xFF90CAF9)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF42A5F5),
        ),
        primaryColor: Color(0xFF42A5F5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF42A5F5),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF42A5F5),
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Color(0xFF42A5F5)),
          trackColor: MaterialStateProperty.all(Color(0xFF90CAF9)),
        ),
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(setDarkMode: setDarkMode, darkMode: darkMode),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => HomePage(setDarkMode: setDarkMode, darkMode: darkMode),
        '/messages': (context) => const MessagesPage(),
        '/favorites': (context) => const FavoritesPage(favorites: []),
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  const LoginPage({super.key, this.setDarkMode, this.darkMode = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    bool hasError = false;
    if (email.isEmpty) {
      setState(() {
        _emailError = 'Wprowadź e-mail';
      });
      hasError = true;
    }
    if (password.isEmpty) {
      setState(() {
        _passwordError = 'Wprowadź hasło';
      });
      hasError = true;
    }
    if (hasError) return;
    setState(() { _isLoading = true; });
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _isLoading = false; });
    Navigator.of(context).pushReplacementNamed('/home');
  }

  int _selectedTab = 0; // 0: login, 1: register

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.darkMode ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Usunięto wszystkie obrazki/logo
                Text(
                  'PetAdopt',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.darkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Zakładki
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Column(
                    children: [
                      Text(
                        'Zaloguj się',
                        style: TextStyle(
                          fontSize: 18,
                          color: _selectedTab == 0
                              ? (widget.darkMode ? Colors.white : Colors.black)
                              : (widget.darkMode ? Colors.white70 : Colors.grey),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 80,
                        margin: const EdgeInsets.only(top: 4),
                        color: _selectedTab == 0 ? Color(0xFF42A5F5) : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Column(
                    children: [
                      Text(
                        'Utwórz konto',
                        style: TextStyle(
                          fontSize: 18,
                          color: _selectedTab == 1
                              ? (widget.darkMode ? Colors.white : Colors.black)
                              : (widget.darkMode ? Colors.white70 : Colors.grey),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 100,
                        margin: const EdgeInsets.only(top: 4),
                        color: _selectedTab == 1 ? Color(0xFF42A5F5) : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _selectedTab == 0 ? _buildLoginForm() : _buildRegisterForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Zaloguj się',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Witaj ponownie!\nZaloguj się i znajdź swojego przyjaciela!',
          style: TextStyle(fontSize: 16, color: widget.darkMode ? Colors.white70 : Colors.black54),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: false,
          style: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: widget.darkMode ? Colors.white70 : null),
            border: const OutlineInputBorder(),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          readOnly: false,
          style: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'Hasło',
            labelStyle: TextStyle(color: widget.darkMode ? Colors.white70 : null),
            border: const OutlineInputBorder(),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: widget.darkMode ? Colors.white70 : null),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Zaloguj',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Zapomniałeś hasła?',
              style: TextStyle(color: widget.darkMode ? Colors.white70 : Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.facebook, color: widget.darkMode ? Colors.white70 : Colors.black54),
              onPressed: () {},
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: Icon(Icons.camera_alt, color: widget.darkMode ? Colors.white70 : Colors.black54), // Instagram placeholder
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Załóż konto',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Dołącz do psindera i znajdź psjajciela!',
          style: TextStyle(fontSize: 16, color: widget.darkMode ? Colors.white70 : Colors.black54),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'E-mail',
            labelStyle: TextStyle(color: widget.darkMode ? Colors.white70 : null),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _registerPasswordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(color: widget.darkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            labelText: 'Hasło',
            labelStyle: TextStyle(color: widget.darkMode ? Colors.white70 : null),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: widget.darkMode ? Colors.white70 : null),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Zarejestruj',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const SizedBox(height: 16),
      ],
    );
  }
}
