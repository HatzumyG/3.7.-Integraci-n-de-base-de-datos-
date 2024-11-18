import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_core/firebase_core.dart';  
import 'firebase_options.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'App Peli';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: const Text(appTitle),
        ),
        body: const SingleChildScrollView(
          child: Stack(
            children: [
              ImageSection(image: 'images/background.jpg'),
              Column(
                children: [
                  TitleSection(
                    name: 'Catálogo de películas',
                    location: 'App Pelis',
                  ),
                  ButtonSection(),
                  TextSection(
                    description:
                        'Catálogo de películas con diferentes géneros y toda la diversión '
                        'en un mismo sitio. Entretenimiento de calidad.',
                  ),
                  MarvelCharactersSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageSection extends StatelessWidget {
  const ImageSection({super.key, required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      image,
      width: double.infinity,
      height: 240,
      fit: BoxFit.cover,
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({
    super.key,
    required this.name,
    required this.location,
  });

  final String name;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.star,
            color: Colors.red[500],
          ),
          const Text('41'),
        ],
      ),
    );
  }
}

class ButtonSection extends StatelessWidget {
  const ButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color color = Theme.of(context).primaryColor;
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ButtonWithText(
            color: color,
            icon: Icons.call,
            label: 'CALL',
          ),
          ButtonWithText(
            color: color,
            icon: Icons.near_me,
            label: 'ROUTE',
          ),
          ButtonWithText(
            color: color,
            icon: Icons.share,
            label: 'SHARE',
          ),
        ],
      ),
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText({
    super.key,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        description,
        softWrap: true,
      ),
    );
  }
}

class MarvelCharactersSection extends StatelessWidget {
  const MarvelCharactersSection({super.key});

  String generateMd5Hash(String timestamp, String privateKey, String publicKey) {
    final input = timestamp + privateKey + publicKey;  
    final bytes = utf8.encode(input); 
    final digest = md5.convert(bytes); 
    return digest.toString(); 
  }

  Future<List<dynamic>> fetchMarvelData() async {

    String publicKey = '87683c6ede8dd412d12608faec31e2a4'; 
    String privateKey = 'ac1e52d2d41893302f6c125179c8b0233eae58f7'; 

    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    String hash = generateMd5Hash(timestamp, privateKey, publicKey);

    String url = 'https://gateway.marvel.com/v1/public/characters?ts=$timestamp&apikey=$publicKey&hash=$hash';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
    
      var data = json.decode(response.body);
      return data['data']['results'];  
    } else {

      throw Exception('Error al obtener los personajes de Marvel');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchMarvelData(),  
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); 
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));  
        } else if (snapshot.hasData) {
          var characters = snapshot.data; 
          return ListView.builder(
            shrinkWrap: true,  
            itemCount: characters?.length ?? 0,
            itemBuilder: (context, index) {
              var character = characters?[index];
              return ListTile(
                title: Text(character['name']),
                subtitle: Text(character['description'] ?? 'Sin descripción'),
                leading: Image.network(
                  '${character['thumbnail']['path']}.${character['thumbnail']['extension']}',
                  width: 50,
                  height: 50,
                ),
              );
            },
          );
        } else {
          return const Center(child: Text('No hay datos disponibles'));
        }
      },
    );
  }
}
