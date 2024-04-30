import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/UserDB.dart';
import '../../helpers/authenticationHelper.dart';

class settingsScreen extends StatefulWidget {
  const settingsScreen({super.key});

  @override
  State<settingsScreen> createState() => _Settings();
}

class _Settings extends State<settingsScreen> {

  Map<String, String> map_layers = {
    "https://tile.jawg.io/jawg-streets/{z}/{x}/{y}{r}.png?access-token=": "Street",
    "https://tile.jawg.io/jawg-dark/{z}/{x}/{y}{r}.png?access-token=": "Dark",
    "https://tile.jawg.io/jawg-terrain/{z}/{x}/{y}{r}.png?access-token=": "Terrain",
    "https://tile.jawg.io/e8fdf365-784b-4999-9321-c2e742a8e037/{z}/{x}/{y}{r}.png?access-token=": "Detailed"
  };

  String unsplash_key = "";
  String map_api_key = "";
  String map_layer = "";
  UserDB? _user;
  bool hasChanges = false;

  Future<UserDB?> getUser() async {
    final user = await UserDB.getBySession(AuthenticationHelper().currentUser);
    if(user != null)
      {
        setState(() {
          _user = user;
          unsplash_key = user.unsplash_api_key;
          map_api_key = user.map_api_key;
          map_layer = user.map_layer;
        });
      }
    return user;
  }

  void _checkForChanges() {
    if (_user == null) return; // Early return if user data not loaded

    // Check if any of the input values differ from the user data
    bool hasInputChanges = unsplash_key != _user!.unsplash_api_key ||
        map_api_key != _user!.map_api_key ||
        map_layer != _user!.map_layer;

    // Update hasChanges based on the comparison
    setState(() {
      hasChanges = hasInputChanges;
    });
  }

  void _submitChanges()
  {
    if(_user != null)
      {
        UserDB newUser = UserDB(
            id: _user!.id,
            name: _user!.name,
            photo_url: _user!.photo_url,
            uid: _user!.uid,
            unsplash_api_key: unsplash_key,
            map_api_key: map_api_key,
            map_layer: map_layer
        );

        newUser.update();
        setState(() {
          hasChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Settings Updated"),
            duration: Duration(seconds: 2),
          ),
        );
      }
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          hasChanges == true
              ? Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton.filledTonal(
              onPressed: () => _submitChanges(),
              icon: const Icon(Icons.check),
            ),
          )
              : const SizedBox(),
        ],
      ),
      body: _user == null ? const Center(
        child: CircularProgressIndicator(),
      ) : Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(75.0), // Adjust radius as needed
                    child: AspectRatio(
                      aspectRatio: 1.0, // Adjust aspect ratio as needed
                      child: Image(
                        image: NetworkImage(_user!.photo_url),
                        fit: BoxFit.cover, // Adjust fit as needed (cover, contain, etc.)
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g. ....',
                  labelText: 'Unsplash API key',
                ),
                initialValue: unsplash_key,
                maxLength: 255,
                onChanged: (value) {
                  setState(() {
                    unsplash_key = value;
                  });
                  _checkForChanges();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g. ....',
                  labelText: 'Map API key',
                ),
                initialValue: map_api_key,
                maxLength: 255,
                onChanged: (value) {
                  setState(() {
                    map_api_key = value;
                  });
                  _checkForChanges();
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                decoration: const InputDecoration(
                  hintText: 'e.g. ....',
                  labelText: 'Map Layer',
                ),
                items: map_layers.entries.map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                )).toList(),
                value: map_layer,
                onChanged: (value) {
                  setState(() {
                    map_layer = value!;
                  });
                  _checkForChanges();
                },
              ),
              const SizedBox(height: 16),
              TextButton(onPressed: () {
                AuthenticationHelper().signOut();
                Navigator.pushNamed(context, '/auth/login');
              }, child: const Text('Log out'))
            ],
          ),
        ),
      ),
    );
  }
}
