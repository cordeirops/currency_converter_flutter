import 'package:cloud_firestore/cloud_firestore.dart';

class Moeda {
  final String nome;
  final double valor;
  final DateTime? atualizadoEm;

  Moeda({
    required this.nome,
    required this.valor,
    this.atualizadoEm
  });

  factory Moeda.fromJson(Map<String, dynamic> json) {
    return Moeda(
      nome: json['code'],
      valor: double.parse(json['bid'].toString()),
      atualizadoEm: DateTime.now(),
    );
  }

  factory Moeda.fromFirestore(Map<String, dynamic> data, String id) {
    return Moeda(
      nome: data['codigo'] ?? id,
      valor: (data['valor'] ?? 0).toDouble(),
      atualizadoEm: data['atualizadoEm'] != null
          ? (data['atualizadoEm'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'codigo': nome,
      'valor': valor,
      'atualizadoEm': atualizadoEm != null ? Timestamp.fromDate(atualizadoEm!) : null,
    };
  }

  @override
  String toString() {
    return 'Moeda{nome: $nome, valor: $valor}';
  }
}