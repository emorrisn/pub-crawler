import 'package:flutter/material.dart';

import '../../../models/City.dart';
import '../../../providers/cityProvider.dart';

class newCrawlDetailsSelectCityScreen extends StatefulWidget {
  const newCrawlDetailsSelectCityScreen({super.key});

  @override
  State<newCrawlDetailsSelectCityScreen> createState() => _CrawlDetailsSelectCityState();
}

class _CrawlDetailsSelectCityState extends State<newCrawlDetailsSelectCityScreen> {

  final TextEditingController searchController = TextEditingController();

  CityProvider cityProvider = CityProvider();
  List<City> cities = [];
  List<City> filteredCities = [];


  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    cities = await cityProvider.getCities();
    filteredCities = List.from(cities); // Initialize filteredCities with all cities
    setState(() {}); // Trigger a rebuild once cities are loaded
  }

  @override
  Widget build(BuildContext context) {
    // Dealing with input persistence across different screens
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String name = args?['name'] ?? '';
    final String description = args?['description'] ?? '';
    final dynamic individualChallenges = args?['individualChallenges'];
    final dynamic groupChallenges = args?['groupChallenges'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City'),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Center(
        child: Column(
          children: [
            SearchBar(
              shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
              leading: IconButton(
                onPressed: () {
                },
                icon: const Icon(Icons.search),
              ),
              elevation: MaterialStateProperty.resolveWith<double?>(
                    (states) {
                  return 1; // Default elevation
                },
              ),
              controller: searchController,
              hintText: "Search...",
              onChanged: (value) {
                setState(() {
                  filteredCities = cities
                      .where((city) => city.name
                      .toLowerCase()
                      .contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: ListView.builder(
                  itemCount: filteredCities.length, // Hardcoded number of items for testing
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    final countryName = filteredCities[index].country;

                    return Column(
                      children: [
                        ListTile(
                          onTap: () => {
                          Navigator.pushNamed(context, '/new', arguments: {
                            'city': city,
                            'name': name,
                            'description': description,
                            'individualChallenges': individualChallenges,
                            'groupChallenges': groupChallenges,
                          })

                          },
                          title: Text(
                            city.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(countryName),
                        ),
                        const Divider()
                      ],
                    );
                  },
                ),
              ),
            ),
            // Add your select locations UI here
          ],
        ),
      ),
    );
  }
}
