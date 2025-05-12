import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/moeda.dart';
import 'api_service.dart';
import 'conta_service.dart';

class CotacaoService {
  final FirebaseFirestore _firestore;
  final ApiService _apiService;
  final ContaService _contaService;
  Timer? _timer;

  final Map<String, Moeda> _cotacoesCache = {};

  final List<String> _moedasFixas = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD'];

  final _cotacoesController = StreamController<List<Moeda>>.broadcast();

  CotacaoService({
    FirebaseFirestore? firestore,
    ApiService? apiService,
    ContaService? contaService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _apiService = apiService ?? ApiService(),
        _contaService = contaService ?? ContaService() {
    _inicializarCotacoes();
  }

  Future<void> _inicializarCotacoes() async {
    try {
      await atualizarCotacoes();
    } catch (e) {
      debugPrint('Erro ao inicializar cotações: $e');
    }
  }

  void iniciarAtualizacaoPeriodica() {
    _timer?.cancel();

    atualizarCotacoes();

    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      atualizarCotacoes();
    });
  }

  void pararAtualizacaoPeriodica() {
    _timer?.cancel();
    _timer = null;
  }

  Future<Map<String, Moeda>> atualizarCotacoes() async {
    try {
      List<String> moedas = [];

      try {
        final snapshot = await _firestore.collection('contas').get();
        moedas = snapshot.docs
            .map((doc) => doc['moeda'] as String)
            .where((moeda) => moeda != 'BRL')
            .toSet()
            .toList();
      } catch (e) {
        debugPrint('Erro ao obter moedas das contas: $e');
      }

      if (moedas.isEmpty) {
        moedas = List.from(_moedasFixas);
      }

      final cotacoes = await _apiService.getCotacoes(moedas);
      final agora = DateTime.now();

      cotacoes.forEach((moeda, valor) {
        _cotacoesCache[moeda] = Moeda(
          nome: moeda,
          valor: valor,
          atualizadoEm: agora,
        );
      });

      try {
        await _contaService.atualizarTodasCotacoes();
      } catch (e) {
        debugPrint('Erro ao atualizar contas: $e');
      }

      _cotacoesController.add(_cotacoesCache.values.toList());

      debugPrint('Cotações atualizadas: ${_cotacoesCache.length} moedas');

      return Map.from(_cotacoesCache);
    } catch (e) {
      debugPrint('Erro ao atualizar cotações: $e');
      if (_cotacoesCache.isNotEmpty) {
        return Map.from(_cotacoesCache);
      }
      throw Exception('Falha ao atualizar cotações: $e');
    }
  }

  Stream<List<Moeda>> getCotacoes() {
    if (_cotacoesCache.isEmpty) {
      atualizarCotacoes().then((_) {
      }).catchError((error) {
        debugPrint('Erro ao buscar cotações iniciais: $error');
        _cotacoesController.add([]);
      });
    } else {
      _cotacoesController.add(_cotacoesCache.values.toList());
    }

    return _cotacoesController.stream;
  }

  Future<double> getCotacaoMoeda(String moeda) async {
    if (moeda == 'BRL') return 1.0;

    if (_cotacoesCache.containsKey(moeda)) {
      return _cotacoesCache[moeda]!.valor;
    }

    try {
      final cotacoes = await _apiService.getCotacoes([moeda]);
      final valor = cotacoes[moeda] ?? 0;

      if (valor > 0) {
        _cotacoesCache[moeda] = Moeda(
          nome: moeda,
          valor: valor,
          atualizadoEm: DateTime.now(),
        );

        _cotacoesController.add(_cotacoesCache.values.toList());
      }

      return valor;
    } catch (e) {
      debugPrint('Erro ao obter cotação de $moeda: $e');
      return 0;
    }
  }

  Future<void> carregarCotacoesFixas() async {
    try {
      final cotacoes = await _apiService.getCotacoes(_moedasFixas);
      final agora = DateTime.now();

      cotacoes.forEach((moeda, valor) {
        _cotacoesCache[moeda] = Moeda(
          nome: moeda,
          valor: valor,
          atualizadoEm: agora,
        );
      });

      _cotacoesController.add(_cotacoesCache.values.toList());
      debugPrint('Cotações fixas carregadas: ${cotacoes.length} moedas');
    } catch (e) {
      debugPrint('Erro ao carregar cotações fixas: $e');
    }
  }

  void dispose() {
    pararAtualizacaoPeriodica();
    _cotacoesController.close();
  }
}