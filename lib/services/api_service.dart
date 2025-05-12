import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://economia.awesomeapi.com.br/json/last/';

  Future<Map<String, double>> getCotacoes(List<String> moedas) async {
    try {
      final pares = moedas.where((m) => m != 'BRL').map((m) => '$m-BRL').join(',');

      final response = await http.get(Uri.parse('$_baseUrl$pares'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseCotacoes(data);
      } else {
        throw Exception('Falha ao carregar cotações: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro na conexão: $e');
    }
  }

  Map<String, double> _parseCotacoes(Map<String, dynamic> data) {
    final cotacoes = <String, double>{};

    data.forEach((key, value) {
      final moeda = key.replaceAll('BRL', '');
      cotacoes[moeda] = double.parse(value['bid']);
    });

    return cotacoes;
  }
}