import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/conta.dart';
import 'api_service.dart';

class ContaService {
  final FirebaseFirestore _firestore;
  final ApiService _apiService;

  ContaService({
    FirebaseFirestore? firestore,
    ApiService? apiService
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
        _apiService = apiService ?? ApiService();

  Future<void> atualizarTodasCotacoes() async {
    try {
      final contas = await _firestore.collection('contas').get();

      if (contas.docs.isEmpty) {
        return;
      }

      final moedas = contas.docs
          .map((doc) => doc['moeda'] as String)
          .where((moeda) => moeda != 'BRL')
          .toSet()
          .toList();

      if (moedas.isEmpty) {
        return;
      }

      final cotacoes = await _apiService.getCotacoes(moedas);
      final batch = _firestore.batch();
      final timestamp = FieldValue.serverTimestamp();

      for (final doc in contas.docs) {
        final moeda = doc['moeda'] as String;
        if (moeda != 'BRL' && cotacoes.containsKey(moeda)) {
          final saldoMoeda = (doc['saldoMoeda'] as num).toDouble();
          final taxaConversao = cotacoes[moeda]!;
          final novoSaldoBRL = saldoMoeda * taxaConversao;

          batch.update(doc.reference, {
            'saldoBRL': novoSaldoBRL,
            'taxaConversao': taxaConversao,
            'ultimaAtualizacao': timestamp,
          });
        }
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Erro ao atualizar cotações: $e');
      throw Exception('Falha ao atualizar cotações: $e');
    }
  }

  Stream<List<Conta>> getContas(String usuarioId) {
    try {
      if (usuarioId.isEmpty) {
        return Stream.value([]);
      }

      return _firestore
          .collection('contas')
          .where('usuarioId', isEqualTo: usuarioId)
          .orderBy('criadoEm')
          .snapshots()
          .handleError((error) {
        debugPrint('Erro ao carregar contas: $error');
        throw Exception('Falha ao carregar contas. Tente novamente.');
      })
          .map((snapshot) => snapshot.docs
          .map((doc) => Conta.fromFirestore(doc.data(), doc.id))
          .toList());
    } catch (e) {
      debugPrint('Erro no getContas: $e');
      return Stream.error(Exception('Falha ao acessar o serviço'));
    }
  }

  Future<void> addConta(Conta conta) async {
    try {
      if (conta.usuarioId.isEmpty) {
        throw Exception('Usuário não autenticado');
      }

      if (conta.moeda != 'BRL') {
        final cotacoes = await _apiService.getCotacoes([conta.moeda]);
        if (cotacoes.containsKey(conta.moeda)) {
          final taxaConversao = cotacoes[conta.moeda]!;
          conta = conta.copyWith(
            saldoBRL: conta.saldoMoeda * taxaConversao,
            taxaConversao: taxaConversao,
          );
        }
      }

      await _firestore.collection('contas').add({
        ...conta.toFirestore(),
        'criadoEm': FieldValue.serverTimestamp(),
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Erro ao adicionar conta: ${e.code} - ${e.message}');
      throw _handleFirestoreError(e);
    } catch (e) {
      debugPrint('Erro inesperado ao adicionar conta: $e');
      throw Exception('Falha ao criar conta');
    }
  }

  Future<void> updateConta(Conta conta) async {
    try {
      if (conta.id == null || conta.id!.isEmpty) {
        throw Exception('ID da conta inválido');
      }

      if (conta.moeda != 'BRL') {
        final cotacoes = await _apiService.getCotacoes([conta.moeda]);
        if (cotacoes.containsKey(conta.moeda)) {
          final taxaConversao = cotacoes[conta.moeda]!;
          conta = conta.copyWith(
            saldoBRL: conta.saldoMoeda * taxaConversao,
            taxaConversao: taxaConversao,
          );
        }
      }

      await _firestore.collection('contas').doc(conta.id).update({
        ...conta.toFirestore(),
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      debugPrint('Erro ao atualizar conta: ${e.code} - ${e.message}');
      throw _handleFirestoreError(e);
    } catch (e) {
      debugPrint('Erro inesperado ao atualizar conta: $e');
      throw Exception('Falha ao atualizar conta');
    }
  }

  Future<void> deleteConta(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('ID inválido');
      }

      await _firestore.collection('contas').doc(id).delete();
    } on FirebaseException catch (e) {
      debugPrint('Erro ao deletar conta: ${e.code} - ${e.message}');
      throw _handleFirestoreError(e);
    } catch (e) {
      debugPrint('Erro inesperado ao deletar conta: $e');
      throw Exception('Falha ao excluir conta');
    }
  }

  Exception _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return Exception('Você não tem permissão para esta ação');
      case 'not-found':
        return Exception('Conta não encontrada');
      case 'unavailable':
        return Exception('Serviço indisponível. Tente novamente mais tarde');
      default:
        return Exception('Erro no servidor: ${e.message}');
    }
  }
}