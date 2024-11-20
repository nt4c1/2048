import 'package:http/http.dart' as http;
import 'dart:convert';

class CountryService {
  static Future<String> fetchCountry() async {
    final url = Uri.parse('https://api.country.is');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['country'] ?? 'Unknown';
    } else {
      throw Exception('Failed to fetch country');
    }
  }
}
