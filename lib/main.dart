import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'contact_us.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'market.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Accueil',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const BasketballCourtPage(),
    );
  }
}

class BasketballCourtPage extends StatefulWidget {
  const BasketballCourtPage({Key? key}) : super(key: key);

  @override
  _BasketballCourtPageState createState() => _BasketballCourtPageState();
}

class _BasketballCourtPageState extends State<BasketballCourtPage> {
  List<Map<String, dynamic>> _players = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:5000/meilleurs-joueurs'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _players = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Échec du chargement des joueurs');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de chargement des données')),
      );
    }
  }

  void _handleLogout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnexion...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                  painter: CourtPainter(),
                ),
                ..._buildPlayerPositions(),
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Positions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('PG - Meneur'),
                        Text('SG - Arrière'),
                        Text('SF - Ailier'),
                        Text('PF - Ailier fort'),
                        Text('C - Pivot'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactUsPage()),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlayerListScreen()),
      );
    } 
    else {
              setState(() {
                _selectedIndex = index;
        });
      }
    },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contact_support),
              label: 'Contact',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sports),
              label: 'Market',
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPlayerPositions() {
    if (_players.isEmpty) return [];

    final positions = [
      _PlayerPosition(
        position: 'PG',
        top: 0.7,
        left: 0.5,
        player: _players.isNotEmpty ? _players[0] : null,
      ),
      _PlayerPosition(
        position: 'SG',
        top: 0.6,
        left: 0.8,
        player: _players.length > 1 ? _players[1] : null,
      ),
      _PlayerPosition(
        position: 'SF',
        top: 0.5,
        left: 0.2,
        player: _players.length > 2 ? _players[2] : null,
      ),
      _PlayerPosition(
        position: 'PF',
        top: 0.3,
        left: 0.7,
        player: _players.length > 3 ? _players[3] : null,
      ),
      _PlayerPosition(
        position: 'C',
        top: 0.2,
        left: 0.5,
        player: _players.length > 4 ? _players[4] : null,
      ),
    ];

    return positions.map((pos) {
      return Positioned(
        top: MediaQuery.of(context).size.height * pos.top,
        left: MediaQuery.of(context).size.width * pos.left,
        child: _buildPlayerMarker(pos),
      );
    }).toList();
  }

  Widget _buildPlayerMarker(_PlayerPosition position) {
    if (position.player == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            position.position,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${position.player!['prenom']} ${position.player!['nom']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${position.player!['score']} pts',
            style: const TextStyle(color: Colors.grey),
        ),
        ],
      ),
    );
  }
}

class _PlayerPosition {
  final String position;
  final double top;
  final double left;
  final Map<String, dynamic>? player;

  _PlayerPosition({
    required this.position,
    required this.top,
    required this.left,
    this.player,
  });
}

class CourtPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Contour du terrain
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.1, 
                    size.width * 0.8, size.height * 0.8),
      paint,
    );

    // Cercle central
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.1,
      paint,
    );

    // Zones de trois points
    final path = Path();
    path.addArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.2),
        radius: size.width * 0.2,
      ),
      0,
      3.14,
    );
    path.addArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.5, size.height * 0.8),
        radius: size.width * 0.2,
      ),
      3.14,
      3.14,
    );
    canvas.drawPath(path, paint);

    // Zones restrictives
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.1,
                    size.width * 0.3, size.height * 0.2),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.35, size.height * 0.7,
                    size.width * 0.3, size.height * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}