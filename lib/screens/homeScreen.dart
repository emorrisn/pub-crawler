import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:pub_hopper_app/models/database_models/CrawlDB.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../helpers/authenticationHelper.dart';
import '../helpers/notificationHelper.dart';
import '../models/database_models/UserDB.dart';
import '../widgets/mapWidget.dart';
import '../widgets/my_crawls/crawlListItem.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _MapPageState();
}

class _MapPageState extends State<HomeScreen> {
  late MapController mapController;
  late PanelController panelController;
  UserDB? _user;
  bool drawerOpen = false;

  Future<UserDB?> getUser() async {
    final user = await UserDB.getBySession(AuthenticationHelper().currentUser);
    setState(() {
      _user = user;
    });
    return user;
  }

  @override
  void initState() {
    super.initState();
    getUser();
    mapController = MapController(); // Initialize map controller
    panelController = PanelController();
    drawerOpen = false;
  }

  void _handlePanelSlide(double slide) {
    setState(() {
      drawerOpen = slide > 0.5; // Adjust the threshold as needed
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SlidingUpPanel(
        controller: panelController,
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        onPanelSlide: _handlePanelSlide,
        panel: DrawerWidget(
          user: _user!,
          isDrawerOpen: drawerOpen,
        ), // Your custom drawer widget
        minHeight: 50, // Height of the collapsed panel
        maxHeight: MediaQuery.of(context).size.height *
            0.95, // Height of the expanded panel
        body: MapWidget(
            mapController: mapController,
            tracking: true,
            user: _user!,
            isDrawerOpen: drawerOpen), // Your map widget or main content
      ),
    );
  }
}

class DrawerWidget extends StatefulWidget {
  final UserDB user;
  final bool isDrawerOpen;

  const DrawerWidget({
    super.key,
    required this.user,
    required this.isDrawerOpen,
  });

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
    _fetchCrawls();
  }

  List<CrawlDB> items = [];
  List<CrawlDB> filteredItems = [];

  final TextEditingController searchController = TextEditingController();

  void _filterCrawls(String query) {
    setState(() {
      filteredItems = items
          .where(
              (crawl) => crawl.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _fetchCrawls() async {
    final crawls = await CrawlDB.getAllCrawls();
    if (mounted) {
      setState(() {
        items = crawls; // Update the items list in the state
        if (filteredItems.isEmpty && searchController.text == "") {
          filteredItems = crawls;
        }
      });
    }
  }

  void _deleteCrawl(CrawlDB crawl) {
    crawl.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Crawl deleted"),
        duration: Duration(seconds: 2),
      ),
    );
    _fetchCrawls();
  }

  void _shareCrawl(CrawlDB crawl) {
    Navigator.pushNamed(context, '/crawl/share', arguments: {'crawl': crawl});
  }

  void _editCrawl(CrawlDB crawl) {
    Navigator.pushNamed(context, '/crawl/edit', arguments: {'crawl': crawl});
  }

  Future<void> _startCrawl(CrawlDB crawl) async {
    await NotificationHelper.showNotification(
        title: "Crawl started!", body: "Are you ready?..");

    if (mounted) {
      Navigator.pushNamed(context, '/crawl', arguments: {
        'crawl': crawl,
        'position': 0,
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchCrawls();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Stack(children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 30,
                    height: 5,
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))),
                  ),
                ],
              ),
            ),
            SearchBar(
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero)),
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              elevation: MaterialStateProperty.resolveWith<double?>(
                (states) {
                  return 0; // Default elevation
                },
              ),
              onChanged: _filterCrawls,
              controller: searchController,
              hintText: "Search your crawls...",
            ),
            const Divider(),
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text('You have no crawls, create one!'),
                    )
                  : ListView.builder(
                      itemCount: filteredItems
                          .length, // Use the length of the fetched crawls
                      itemBuilder: (context, index) {
                        final CrawlDB crawl =
                            filteredItems[index]; // Get the CrawlDB object
                        return AnimatedOpacity(
                          opacity: widget.isDrawerOpen ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: CrawlListItem(
                                  crawl: crawl,
                                  onDeleteCrawl: _deleteCrawl,
                                  onShareCrawl: _shareCrawl,
                                  onEditCrawl: _editCrawl,
                                  onStartCrawl: _startCrawl,
                                  apiKey: widget.user.unsplash_api_key,
                                ),
                              ),
                              const Divider()
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // Add more list items as needed
          ],
        ),
        AnimatedPositioned(
            bottom: 105.0,
            right: widget.isDrawerOpen ? 25.0 : -100.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'qr_code',
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.pushNamed(context, '/qr');
              },
              child: const Icon(Icons.qr_code),
            )),
        AnimatedPositioned(
            bottom: 25.0,
            right: widget.isDrawerOpen ? 25.0 : -100.0,
            duration: const Duration(milliseconds: 300),
            child: FloatingActionButton(
              heroTag: 'new_crawl',
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: const CircleBorder(),
              onPressed: () {
                Navigator.pushNamed(context, '/new');
              },
              child: const Icon(Icons.add_location_outlined),
            )),
      ]),
    );
  }
}
