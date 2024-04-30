import 'dart:convert';
import 'package:http/http.dart' as http;

class UnsplashAPIService {


  static const _baseUrl = 'https://api.unsplash.com';
  String _unsplashAccessToken = '';

  Future<RandomPhoto> getRandomPhoto({String query = '', required String apikey}) async {
    _unsplashAccessToken = apikey;

    final url = Uri.parse('$_baseUrl/photos/random?${query != '' ? 'query=$query' : ''}&q=1');

    final headers = {'Authorization': 'Client-ID $_unsplashAccessToken'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return RandomPhoto.fromJson(jsonResponse);
    } else {
      if(response.body == "Rate Limit Exceeded")
      {
        throw Exception('Rate Limit Exceeded: ${response.statusCode}');
      }
      throw Exception('Failed to fetch random photo: ${response.statusCode}');
    }
  }
}

class RandomPhoto {
  final String id;
  final String imageUrl;
  final String description;

  RandomPhoto.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        imageUrl = json['urls']['regular'],
        description = json['description'] ?? '';
}
