import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/UserDB.dart';

import '../../helpers/authenticationHelper.dart';
import '../../helpers/databaseHelper.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({super.key});

  @override
  State<loginScreen> createState() => _Login();
}

class _Login extends State<loginScreen> {
  bool _loading = false;

  @override
  void initState() {
    _loading = false;
    super.initState();
  }

  Future<void> _authenticate() async {
    setState(() {
      _loading = true;
    });

    User? auth = await AuthenticationHelper().signInWithGoogle();
    UserDB? user;

    try {
      if (auth != null) {
        List<Map<String, dynamic>> users = await DatabaseHelper()
            .getAll('Users', where: 'uid = ?', whereArgs: [auth.uid]);
        if (users.isNotEmpty) {
          user = UserDB.fromMap(users.first);
        } else {
          user = UserDB(
              id: 0,
              name: auth.displayName ?? '',
              photo_url: auth.photoURL ?? '',
              uid: auth.uid,
              unsplash_api_key: '',
              map_api_key: '',
              map_layer: '');
          int userID = await user.insert();
          user = await UserDB.getById(userID);
        }
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      _loading = false;
    });

    // authenticationHelper().signOut();

    if(user != null) {
      if(user.unsplash_api_key == '' || user.map_api_key == ''|| user.map_layer == '') {
        // Navigate to register
        if(mounted)
          {
            Navigator.pushNamed(context, '/auth/register', arguments: {
              'user': user
            });
          }
      } else {
        if(mounted)
          {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Welcome back ${user.name}!"),
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pushNamed(context, '/');
          }
      }
      setState(() {});
    } else {
      if(mounted)
        {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Something went wrong, please try again."),
              duration: Duration(seconds: 2),
            ),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 200,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Image(
          image: AssetImage('assets/images/logos/light_hori.png'),
          semanticLabel: "Pub Crawler",
        ),
      ),
      body: Center(
        child: _loading ? const CircularProgressIndicator() : Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0),
          child: ElevatedButton(
            onPressed: () {
              // Trigger the sign-in with Google function
              _authenticate();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login), // Google icon
                SizedBox(width: 8), // Adjust spacing between icon and text
                Text('Sign in with Google'), // Button text
              ],
            ),
          ),
        ),
      ),
    );
  }
}
