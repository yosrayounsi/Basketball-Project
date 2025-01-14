import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'contact_us.dart';
class Player {
  final String name;
  final String position;
  final int points;
  final int rebounds;
  final int assists;
  final String email;
  final String phone;
  final String imageUrl;

  Player({
    required this.name,
    required this.position,
    required this.points,
    required this.rebounds,
    required this.assists,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });
}

Future<List<Player>> fetchPlayers() async {
  const String apiUrl = 'https://projectmaster-6cc96-default-rtdb.europe-west1.firebasedatabase.app/equipes.json';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    try {
      final data = jsonDecode(response.body);

      List<dynamic> locauxJoueuses = data['locaux']['joueuses'];
      List<dynamic> visiteursJoueuses = data['visiteurs']['joueuses'];

      List<Player> players = [];

      for (var playerData in [...locauxJoueuses, ...visiteursJoueuses]) {
        players.add(Player(
          name: playerData['prenom'] + ' ' + playerData['nom'],
          position: playerData['poste'] ?? 'Inconnu',
          points: playerData['pts_marques'] ?? 0,
          rebounds: playerData['tirs_reussis'] ?? 0,
          assists: playerData['fautes'] ?? 0,
          email: 'email@exemple.com',
          phone: '123-456-7890',
          imageUrl: playerData['photo'] ?? 'https://example.com/default_image.jpg',
        ));
      }
      return players;
    } catch (e) {
      throw Exception('Erreur de décodage JSON: $e');
    }
  } else {
    throw Exception('Erreur lors du chargement des données: ${response.statusCode}');
  }
}

class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  _PlayerListScreenState createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Navigate to Home
      Navigator.pop(context);
    }
    else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ContactUsPage()),
      );

    }
    // Add other navigation actions here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basketball Stats'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Player>>(
        future: fetchPlayers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune donnée disponible'));
          } else {
            final players = snapshot.data!;
            return ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  color: Colors.orange.shade100,
                  child: ExpansionTile(
                    title: Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      player.position,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Statistiques',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatCard('Points', player.points),
                                _buildStatCard('Rebonds', player.rebounds),
                                _buildStatCard('Passes', player.assists),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Contact',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ListTile(
                              leading: const Icon(Icons.email, color: Colors.orange),
                              title: Text(player.email),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone, color: Colors.orange),
                              title: Text(player.phone),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
