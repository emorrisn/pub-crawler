
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../helpers/notificationHelper.dart';
import '../../models/Crawl.dart';

class newCrawlFinaliseScreen extends StatefulWidget {
  const newCrawlFinaliseScreen({super.key});

  @override
  State<newCrawlFinaliseScreen> createState() => _FinaliseScreen();
}

class _FinaliseScreen extends State<newCrawlFinaliseScreen> {
  bool isSaving = false;
  late Crawl crawl;
  final _audioPlayer = AudioPlayer();

  Future<void> _saveCrawl()
  async {
    await _audioPlayer.play(AssetSource("audio/ta-da.wav"));

    await NotificationHelper.showNotification(
        title: "Crawl created!",
        body: "You can edit this crawl once it's created by clicking crawl > edit."
    );
    setState(() {
      isSaving = true;
    });
    await crawl.saveToDatabase();
    setState(() {
      isSaving = false;
    });
    if(mounted)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Crawl created"),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      crawl = args['crawl'] as Crawl;
      // print(crawl);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Save crawl?"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${crawl.locations.length.toString()} Locations, ${crawl.city.name}."),
            const SizedBox(height: 20),
            (isSaving == false) ? ElevatedButton(
              onPressed: () {
                _saveCrawl();
              },
              child: const Text("Save Crawl"),
            ) : const Text('Something went wrong...'),
            const SizedBox(height: 20),
            if (isSaving) const CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}
