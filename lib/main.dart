import 'package:flutter/material.dart';

import 'package:pub_hopper_app/helpers/authenticationHelper.dart';
import 'package:pub_hopper_app/helpers/notificationHelper.dart';
import 'package:pub_hopper_app/screens/authentication/RegisterScreen.dart';
import 'package:pub_hopper_app/screens/crawlScreen.dart';
import 'package:pub_hopper_app/screens/edit_crawl/challenges/editCrawlLocationChallengesScreen.dart';
import 'package:pub_hopper_app/screens/edit_crawl/details/editCrawlDetailsSelectCityScreen.dart';
import 'package:pub_hopper_app/screens/edit_crawl/editCrawlScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/details/newCrawlDetailsSelectCityScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlDetailsScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlFinaliseScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlOrderLocationsScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlSelectChallengesScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/newCrawlSelectLocationsScreen.dart';
import 'package:pub_hopper_app/screens/new_crawl/selectChallenges/newCrawlSelectChallengesLocationScreen.dart';
import 'package:pub_hopper_app/screens/settingsScreen.dart';
import 'package:pub_hopper_app/screens/share_crawl/processCodeScreen.dart';

import '/styling/color_schemes.dart';
import 'helpers/databaseHelper.dart';
import 'models/database_models/UserDB.dart';
import 'screens/authentication/LoginScreen.dart';
import 'screens/share_crawl/shareCrawlScreen.dart';
import 'screens/homeScreen.dart';
import 'screens/share_crawl/scanQRCodeScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await initializeDatabase();

  // Authentication
  await initializeAuthentication();

  // Notifications
  await NotificationHelper.initializeNotifications();

  // .ENV
  await dotenv.load(fileName: ".env");

  // Run the app
  runApp(const MyApp());
}

Future<void> initializeAuthentication() async {
  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if there isn't any users, if there isn't but there is a session then logout.
  List<UserDB> users = await UserDB.getAll();
  if(users.isEmpty && AuthenticationHelper().currentUser != null)
    {
      AuthenticationHelper().signOut();
    }

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
}

Future<void> initializeDatabase() async {
  // Create an instance of your DatabaseHelper class
  final dbHelper = DatabaseHelper();

  // Open the database
  final db = await dbHelper.database;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            return MaterialApp(
              theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
              darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
              themeMode: ThemeMode.dark,
              title: 'Pub Hopper',
              debugShowCheckedModeBanner: false,
              showPerformanceOverlay: false,
              initialRoute: snapshot.hasData ? '/' : '/auth/login',
              routes: {
                '/': (context) => const HomeScreen(),
                '/qr': (context) => const scanQRCodeScreen(),
                '/qr/process': (context) => const processCodeScreen(),
                '/new': (context) => const newCrawlDetailsScreen(),
                '/new/select-locations': (context) => const newCrawlSelectLocationsScreen(),
                '/new/details/select-city': (context) =>
                    const newCrawlDetailsSelectCityScreen(),
                '/new/order-locations': (context) => const newCrawlOrderLocationsScreen(),
                '/new/select-challenges': (context) => const newCrawlSelectChallengesScreen(),
                '/new/select-challenges/location': (context) =>
                    const newCrawlSelectChallengesLocationScreen(),
                '/new/finalise': (context) => const newCrawlFinaliseScreen(),
                '/crawl/share': (context) => const shareCrawlScreen(),
                '/crawl/edit': (context) => const editCrawlScreen(),
                '/crawl/edit/select-city': (context) =>
                    const editCrawlDetailsSelectCityScreen(),
                '/crawl/edit/location/challenges': (context) =>
                    const editCrawlLocationChallengesScreen(),
                '/auth/login': (context) => const loginScreen(),
                '/auth/register': (context) => const registerScreen(),
                '/settings': (context) => const settingsScreen(),
                '/crawl': (context) => const crawlScreen(),
              },
            );
          }
        });
  }
}
