import 'package:flutter/material.dart';
import 'package:pub_hopper_app/models/database_models/CrawlDB.dart';

import '../../services/unsplashAPI.dart';

class CrawlListItem extends StatefulWidget {
  final CrawlDB crawl;
  final String apiKey;

  final Function(CrawlDB) onDeleteCrawl;
  final Function(CrawlDB) onShareCrawl;
  final Function(CrawlDB) onEditCrawl;
  final Function(CrawlDB) onStartCrawl;

  const CrawlListItem({
    Key? key,
    required this.apiKey,
    required this.crawl,
    required this.onDeleteCrawl,
    required this.onShareCrawl,
    required this.onEditCrawl,
    required this.onStartCrawl,
  }) : super(key: key);

  @override
  State<CrawlListItem> createState() => _CrawlListItemState();
}

class _CrawlListItemState extends State<CrawlListItem> {
  final UnsplashAPIService unsplashService = UnsplashAPIService();
  String imageUrl = "";
  List<PopupMenuEntry<String>> popupItems = [
    const PopupMenuItem<String>(
      value: 'start',
      child: Text('Start Crawl'),
    ),
    const PopupMenuItem<String>(
      value: 'edit',
      child: Text('Edit Details'),
    ),
    const PopupMenuItem<String>(
      value: 'share',
      child: Text('Share'),
    ),
    const PopupMenuItem<String>(
      value: 'delete',
      child: Text('Delete'),
    ),
  ];

  Future<void> _getRandomImage() async {
    if (imageUrl == "") {
      try {
        RandomPhoto photo = await unsplashService.getRandomPhoto(
            apikey: widget.apiKey, query: '${widget.crawl.city} city');
        setState(() {
          imageUrl = photo.imageUrl;
        });
      } on Exception catch (error) {
        debugPrint(error.toString());
        setState(() {
          imageUrl = "!";
        });
      }
    }
  }

  void onSelected(String value)
  {
    if (value == "delete") {
      widget.onDeleteCrawl(widget.crawl);
    }
    if (value == "share") {
      widget.onShareCrawl(widget.crawl);
    }
    if (value == "edit") {
      widget.onEditCrawl(widget.crawl);
    }
    if (value == "start") {
      widget.onStartCrawl(widget.crawl);
    }
  }

  @override
  void initState() {
    super.initState();
    _getRandomImage();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.crawl.name),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onSelected("start");
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        child: Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Icon(
            Icons.play_arrow, // Icon to indicate start action
            color: Theme.of(context).colorScheme.onPrimary,
            size: 40.0,
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        offset: Offset.fromDirection(1, 1),
        onSelected: (String value) => onSelected(value),
        itemBuilder: (BuildContext context) => popupItems,
        child: Column(
          children: [
            SizedBox(
              width: 500,
              child: imageUrl != ""
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(10), // Adjust the value as needed
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Theme.of(context).colorScheme.secondary,
                          image: imageUrl != "!"
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl == "!"
                            ? Center(
                                child: Text(
                                  widget.crawl.city[0],
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .background),
                                ),
                              )
                            : null,
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
            ListTile(
              dense: false,
              enableFeedback: true,
              title: Text(
                widget.crawl.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(widget.crawl.description),
            ),
          ],
        ),
      ),
    );
  }
}
