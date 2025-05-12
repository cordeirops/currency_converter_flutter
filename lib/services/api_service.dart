
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://economia.awesomeapi.com.br/json/last/';

  Future<Map<String, double>> getCotacoes(List<String> moedas) async {
    try {
      final moedasFiltradas = moedas
          .where((m) => m.isNotEmpty && m != 'BRL')
          .toSet()
          .toList();

      if (moedasFiltradas.isEmpty) {
        debugPrint('Nenhuma moeda válida para buscar cotação');
        return {};
      }

      debugPrint('Buscando cotações para: $moedasFiltradas');

      final pares = moedasFiltradas.map((m) => '$m-BRL').join(',');
      final uri = Uri.parse('$_baseUrl$pares');

      debugPrint('URL de requisição: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Resposta da API: ${response.body.substring(
            0, min(100, response.body.length))}...');
        return _parseCotacoes(data);
      } else {
        debugPrint('Erro HTTP ${response.statusCode}: ${response.body}');
        throw Exception('Falha ao carregar cotações: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro na API de cotações: $e');
      throw Exception('Erro na conexão: $e');
    }
  }

  Map<String, double> _parseCotacoes(Map<String, dynamic> data) {
    final cotacoes = <String, double>{};

    try {
      data.forEach((key, value) {
        try {
          final moeda = key.substring(0, 3);
          if (value is Map && value.containsKey('bid')) {
            final bid = value['bid'];
            if (bid != null) {
              double taxa;
              if (bid is String) {
                taxa = double.tryParse(bid) ?? 0.0;
              } else if (bid is num) {
                taxa = bid.toDouble();
              } else {
                taxa = 0.0;
              }

              if (taxa > 0) {
                cotacoes[moeda] = taxa;
              }
            }
          }
        } catch (e) {
          debugPrint('Erro ao processar moeda $key: $e');
        }
      });

      debugPrint('Cotações processadas: ${cotacoes.length}');
      return cotacoes;
    } catch (e) {
      debugPrint('Erro no parsing das cotações: $e');
      return {};
    }
  }
}