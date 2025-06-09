// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'home_page.dart';
import 'messages_page.dart';
import 'favorites_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

/// Główna funkcja uruchamiająca aplikację.
void main() {
  runApp(const MyApp());
}

/// Główna klasa aplikacji.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

/// Stan aplikacji, obsługuje tryb ciemny i logikę logowania.
class _MyAppState extends State<MyApp> {
  // Czy tryb ciemny jest aktywny
  bool darkMode = false;
  // Email aktualnie zalogowanego użytkownika
  String? _loggedInEmail;

  /// Ustawia tryb ciemny aplikacji.
  void setDarkMode(bool value) {
    setState(() {
      darkMode = value;
    });
  }

  /// Buduje główny widget MaterialApp z routingiem i motywami.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Logowanie',
      theme: ThemeData.light().copyWith(
        colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF42A5F5),
        ),
        primaryColor: Color(0xFF42A5F5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF42A5F5)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Color(0xFF42A5F5)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF42A5F5)),
          trackColor: WidgetStateProperty.all(const Color(0xFF90CAF9)),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ThemeData.dark().colorScheme.copyWith(
          primary: Color(0xFF42A5F5),
          secondary: Color(0xFF42A5F5),
        ),
        primaryColor: Color(0xFF42A5F5),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF42A5F5)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Color(0xFF42A5F5)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.all(const Color(0xFF42A5F5)),
          trackColor: WidgetStateProperty.all(const Color(0xFF90CAF9)),
        ),
      ),
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoginPage(
        setDarkMode: setDarkMode,
        darkMode: darkMode,
        onLogin: (email) {
          setState(() {
            _loggedInEmail = email;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home':
            (context) => HomePage(
              setDarkMode: setDarkMode,
              darkMode: darkMode,
              currentUserEmail: _loggedInEmail,
            ),
        '/messages': (context) {
          // Zawsze pobieraj najnowszy _loggedInEmail ze stanu aplikacji
          return MessagesPage(currentUserEmail: _loggedInEmail);
        },
        '/favorites': (context) => const FavoritesPage(favorites: []),
      },
    );
  }
}

/// Strona logowania i rejestracji użytkownika.
class LoginPage extends StatefulWidget {
  final void Function(bool)? setDarkMode;
  final bool darkMode;
  final void Function(String email)? onLogin;
  const LoginPage({
    super.key,
    this.setDarkMode,
    this.darkMode = false,
    this.onLogin,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// Stan strony logowania/rejestracji, obsługuje formularze i logikę autoryzacji.
class _LoginPageState extends State<LoginPage> {
  // Kontrolery do obsługi pól tekstowych formularzy.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();

  // Zmienne stanu formularzy
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  int _selectedTab = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  /// Loguje użytkownika do aplikacji
  Future<void> _login() async {
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
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['user'] != null && data['user']['email'] == email) {
          if (widget.onLogin != null) widget.onLogin!(email);
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          setState(() {
            _passwordError = 'Nieprawidłowy email lub hasło';
          });
        }
      } else {
        setState(() {
          _passwordError = data['message'] ?? 'Nieprawidłowy email lub hasło';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = 'Błąd połączenia z serwerem';
      });
    }
  }

  /// Rejestruje nowego użytkownika
  Future<void> _register() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
    String email = _registerEmailController.text.trim();
    String password = _registerPasswordController.text.trim();
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
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200 && data['success'] == true) {
        _emailController.text = email;
        _passwordController.text = password;
        setState(() {
          _selectedTab = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rejestracja zakończona sukcesem!')),
        );
      } else {
        setState(() {
          _emailError = data['message'] ?? 'Błąd rejestracji';
          _passwordError =
              data['message']?.contains('hasło') == true
                  ? data['message']
                  : null;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _emailError = 'Błąd połączenia z serwerem';
      });
    }
  }

  /// Resetuje hasło użytkownika
  Future<void> _forgotPassword() async {
    setState(() {
      _emailError = null;
      _isLoading = true;
    });
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
        _emailError = 'Wprowadź e-mail do resetu hasła';
      });
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      final data = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Nowe hasło wysłane na e-mail'),
          ),
        );
      } else {
        setState(() {
          _emailError = data['message'] ?? 'Błąd resetowania hasła';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _emailError = 'Błąd połączenia z serwerem';
      });
    }
  }

  /// Buduje widget strony logowania/rejestracji.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.darkMode ? Colors.grey[900] : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Napis aplikacji
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          color:
                              _selectedTab == 0
                                  ? (widget.darkMode
                                      ? Colors.white
                                      : Colors.black)
                                  : (widget.darkMode
                                      ? Colors.white70
                                      : Colors.grey),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 80,
                        margin: const EdgeInsets.only(top: 4),
                        color:
                            _selectedTab == 0
                                ? Color(0xFF42A5F5)
                                : Colors.transparent,
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
                          color:
                              _selectedTab == 1
                                  ? (widget.darkMode
                                      ? Colors.white
                                      : Colors.black)
                                  : (widget.darkMode
                                      ? Colors.white70
                                      : Colors.grey),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        height: 3,
                        width: 100,
                        margin: const EdgeInsets.only(top: 4),
                        color:
                            _selectedTab == 1
                                ? Color(0xFF42A5F5)
                                : Colors.transparent,
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
                  child:
                      _selectedTab == 0
                          ? _buildLoginForm()
                          : _buildRegisterForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Buduje formularz logowania.
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
          'Witaj ponownie!',
          style: TextStyle(
            fontSize: 16,
            color: widget.darkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: false,
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(
              color: widget.darkMode ? Colors.white70 : null,
            ),
            border: const OutlineInputBorder(),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          readOnly: false,
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Hasło',
            labelStyle: TextStyle(
              color: widget.darkMode ? Colors.white70 : null,
            ),
            border: const OutlineInputBorder(),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: widget.darkMode ? Colors.white70 : null,
              ),
              onPressed:
                  () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                _isLoading
                    ? null
                    : () async {
                      FocusScope.of(context).unfocus();
                      await _login();
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
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
            onPressed: _isLoading ? null : _forgotPassword,
            child: Text(
              'Zapomniałeś hasła?',
              style: TextStyle(
                color: widget.darkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ],
        ),
        const SizedBox(height: 24),
        const SizedBox(height: 16),
      ],
    );
  }

  /// Buduje formularz rejestracji.
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
          'Dołącz do PetAdopt!',
          style: TextStyle(
            fontSize: 16,
            color: widget.darkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'E-mail',
            labelStyle: TextStyle(
              color: widget.darkMode ? Colors.white70 : null,
            ),
            border: const OutlineInputBorder(),
            errorText: _emailError,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _registerPasswordController,
          obscureText: !_isPasswordVisible,
          style: TextStyle(
            color: widget.darkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            labelText: 'Hasło',
            labelStyle: TextStyle(
              color: widget.darkMode ? Colors.white70 : null,
            ),
            border: const OutlineInputBorder(),
            errorText: _passwordError,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: widget.darkMode ? Colors.white70 : null,
              ),
              onPressed:
                  () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF42A5F5),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Text(
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

/// Zwraca bazowy adres URL API w zależności od platformy
String getApiBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:5000';
  } else if (Platform.isIOS) {
    return 'http://localhost:5000';
  } else {
    return 'http://localhost:5000';
  }
}
