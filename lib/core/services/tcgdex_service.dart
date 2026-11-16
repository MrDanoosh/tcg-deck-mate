import '../../features/cards/tcgdex_card.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TcgDexService {
  static const String baseUrl =
      'https://api.tcgdex.net/v2/en';

 
Future<List<TcgDexCard>> searchCards(String name) async {
  final uri = Uri.parse('$baseUrl/cards').replace(
    queryParameters: {
      'name': name,
      'pagination:page': '1',
      'pagination:itemsPerPage': '20',
    },
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    return data
        .map((card) => TcgDexCard.fromJson(card))
        .toList();
  }

  throw Exception(
    'TCGdex request failed: ${response.statusCode}',
  );
}


  
Future<Map<String, dynamic>> getCard(String id) async {
  final uri = Uri.parse('$baseUrl/cards/$id');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  throw Exception(
    'Unable to retrieve card: ${response.statusCode}',
  );
}

Future<Map<String, dynamic>> getSet(String setId) async {
  final uri = Uri.parse('$baseUrl/sets/$setId');

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  throw Exception(
    'Unable to retrieve set: ${response.statusCode}',
  );
}

Future<Map<String, dynamic>> getCardBySetAndNumber(
  String setId,
  String cardNumber,
) async {
  final uri = Uri.parse(
    '$baseUrl/sets/$setId/$cardNumber',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body)
        as Map<String, dynamic>;
  }

  throw Exception(
    'Unable to retrieve card: ${response.statusCode}',
  );
}


}
