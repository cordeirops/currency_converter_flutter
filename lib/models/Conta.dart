import 'package:cloud_firestore/cloud_firestore.dart';

class Conta {
  String? id;
  final String nome;
  final String moeda;
  final double saldoMoeda;
  double saldoBRL;
  final String usuarioId;
  final DateTime criadoEm;
  DateTime ultimaAtualizacao;
  double taxaConversao;

  Conta({
    this.id,
    required this.nome,
    required this.moeda,
    required this.saldoMoeda,
    required this.usuarioId,
    this.saldoBRL = 0,
    DateTime? criadoEm,
    DateTime? ultimaAtualizacao,
    this.taxaConversao = 0,
  })  : criadoEm = criadoEm ?? DateTime.now(),
        ultimaAtualizacao = ultimaAtualizacao ?? DateTime.now(),
        assert(moeda != 'BRL', 'A moeda não pode ser BRL');

  Conta copyWith({
    String? id,
    String? nome,
    String? moeda,
    double? saldoMoeda,
    double? saldoBRL,
    String? usuarioId,
    DateTime? criadoEm,
    DateTime? ultimaAtualizacao,
    double? taxaConversao,
  }) {
    return Conta(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      moeda: moeda ?? this.moeda,
      saldoMoeda: saldoMoeda ?? this.saldoMoeda,
      saldoBRL: saldoBRL ?? this.saldoBRL,
      usuarioId: usuarioId ?? this.usuarioId,
      criadoEm: criadoEm ?? this.criadoEm,
      ultimaAtualizacao: ultimaAtualizacao ?? this.ultimaAtualizacao,
      taxaConversao: taxaConversao ?? this.taxaConversao,
    );
  }

  void atualizarCotacao(double novaCotacao) {
    taxaConversao = novaCotacao;
    saldoBRL = saldoMoeda * novaCotacao;
    ultimaAtualizacao = DateTime.now();
  }

  factory Conta.fromFirestore(Map<String, dynamic> data, String id) {
    return Conta(
      id: id,
      nome: data['nome'] ?? '',
      moeda: data['moeda'] ?? 'USD',
      saldoMoeda: (data['saldoMoeda'] ?? 0).toDouble(),
      saldoBRL: (data['saldoBRL'] ?? 0).toDouble(),
      usuarioId: data['usuarioId'] ?? '',
      criadoEm: data['criadoEm'] != null
          ? (data['criadoEm'] as Timestamp).toDate()
          : null,
      ultimaAtualizacao: data['ultimaAtualizacao'] != null
          ? (data['ultimaAtualizacao'] as Timestamp).toDate()
          : null,
      taxaConversao: (data['taxaConversao'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nome': nome,
      'moeda': moeda,
      'saldoMoeda': saldoMoeda,
      'saldoBRL': saldoBRL,
      'usuarioId': usuarioId,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'ultimaAtualizacao': Timestamp.fromDate(ultimaAtualizacao),
      'taxaConversao': taxaConversao,
    };
  }

  @override
  String toString() {
    return 'Conta{id: $id, nome: $nome, moeda: $moeda, saldoMoeda: $saldoMoeda, saldoBRL: $saldoBRL, taxa: $taxaConversao}';
  }
}