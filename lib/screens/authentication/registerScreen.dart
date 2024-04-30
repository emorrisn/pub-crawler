import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/UserDB.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class registerScreen extends StatefulWidget {
  const registerScreen({super.key});

  @override
  State<registerScreen> createState() => _Register();
}

class _Register extends State<registerScreen> {
  late TextEditingController _unsplashController;
  late TextEditingController _mapController;
  late TextEditingController _mapLayerController;

  @override
  void initState() {
    super.initState();
    _unsplashController = TextEditingController();
    _mapController = TextEditingController();
    _mapLayerController = TextEditingController();
  }

  @override
  void dispose() {
    _unsplashController.dispose();
    _mapController.dispose();
    _mapLayerController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    String unsplashApiKey = _unsplashController.text.trim();
    String mapApiKey = _mapController.text.trim();
    String mapLayer = _mapLayerController.text.trim();

    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Extract the user data
    final UserDB? user = args?['user'];

    if (user != null) {
      UserDB newUser = UserDB(
          id: user.id,
          name: user.name,
          photo_url: user.photo_url,
          uid: user.uid,
          unsplash_api_key: unsplashApiKey,
          map_api_key: mapApiKey,
          map_layer: mapLayer
      );

      newUser.update();

      // Navigate to the next screen after registration
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong, please try again."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Demo purposes
    if(dotenv.isInitialized == true)
    {
      setState(() {
        _unsplashController.text = dotenv.env['unsplashApiKey']!;
        _mapController.text = dotenv.env['mapApiKey']!;
        _mapLayerController.text = "https://tile.jawg.io/jawg-streets/{z}/{x}/{y}{r}.png?access-token=";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Image(
          image: AssetImage('assets/images/logos/light_hori.png'),
          semanticLabel: "Pub Crawler",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _unsplashController,
              decoration: const InputDecoration(
                hintText: 'e.g. ....',
                labelText: 'Unsplash API key',
              ),
              maxLength: 255,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mapController,
              decoration: const InputDecoration(
                hintText: 'e.g. ....',
                labelText: 'Map API key',
              ),
              maxLength: 255,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mapLayerController,
              decoration: const InputDecoration(
                hintText: 'e.g. ....',
                labelText: 'Map Layer',
              ),
              maxLength: 255,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Complete Registration'),
            ),
          ],
        ),
      ),
    );
  }
}
