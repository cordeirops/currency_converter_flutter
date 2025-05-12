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

      final moedas = contas.docs
          .map((doc) => doc['moeda'] as String)
          .toSet()
          .toList();

      final cotacoes = await _apiService.getCotacoes(moedas);

      final batch = _firestore.batch();

      for (final doc in contas.docs) {
        final moeda = doc['moeda'] as String;
        if (cotacoes.containsKey(moeda)) {
          final saldoMoeda = doc['saldoMoeda'] as double;
          final novoSaldoBRL = saldoMoeda * cotacoes[moeda]!;

          batch.update(doc.reference, {
            'saldoBRL': novoSaldoBRL,
            'ultimaAtualizacao': FieldValue.serverTimestamp(),
          });
        }
      }

      await batch.commit();
    } catch (e) {
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

      await _firestore.collection('contas').add({
        ...conta.toFirestore(),
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
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

      await _firestore.collection('contas').doc(conta.id).update({
        ...conta.toFirestore(),
        'atualizadoEm': FieldValue.serverTimestamp(),
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