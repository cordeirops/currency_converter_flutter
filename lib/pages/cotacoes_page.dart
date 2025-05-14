import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/moeda.dart';
import '../services/cotacao_service.dart';
import '../widgets/app_footer.dart';

class CotacoesPage extends StatefulWidget {
  const CotacoesPage({Key? key}) : super(key: key);

  @override
  _CotacoesPageState createState() => _CotacoesPageState();
}

class _CotacoesPageState extends State<CotacoesPage> {
  bool _isLoading = false;
  final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatoData = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cotacaoService = Provider.of<CotacaoService>(context, listen: false);
      cotacaoService.carregarCotacoesFixas().catchError((error) {
        debugPrint('Erro ao buscar cotações iniciais: $error');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cotacaoService = Provider.of<CotacaoService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotações de Moedas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/contas');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar cotações',
            onPressed: () => _atualizarCotacoes(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.account_balance_wallet),
                    label: const Text('Voltar para Contas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/contas');
                    },
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder<List<Moeda>>(
                stream: cotacaoService.getCotacoes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Erro ao carregar cotações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Tentar novamente'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _atualizarCotacoes(context),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.currency_exchange,
                            size: 64,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Nenhuma cotação disponível',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Carregue as cotações para visualizá-las',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.download),
                            label: const Text('Carregar moedas padrão'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              setState(() => _isLoading = true);

                              try {
                                await cotacaoService.carregarCotacoesFixas();
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro: $e'),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  final moedas = snapshot.data!;

                  final Map<String, IconData> moedasIcons = {
                    'BRL': Icons.attach_money,
                    'USD': Icons.attach_money,
                    'EUR': Icons.euro_symbol,
                    'GBP': Icons.currency_pound,
                    'JPY': Icons.currency_yen,
                    'CAD': Icons.monetization_on,
                    'AUD': Icons.monetization_on,
                    'CHF': Icons.monetization_on,
                  };

                  final Map<String, Color> moedasColors = {
                    'BRL': Colors.green,
                    'USD': Colors.blue,
                    'EUR': Colors.indigo,
                    'GBP': Colors.purple,
                    'JPY': Colors.red,
                    'CAD': Colors.orange,
                    'AUD': Colors.amber.shade800,
                    'CHF': Colors.teal,
                  };

                  return RefreshIndicator(
                    onRefresh: () => _atualizarCotacoes(context),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: moedas.length,
                      itemBuilder: (context, index) {
                        final moeda = moedas[index];
                        final IconData moedaIcon = moedasIcons[moeda.nome] ?? Icons.currency_exchange;
                        final Color moedaColor = moedasColors[moeda.nome] ?? Colors.blue;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: moedaColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: moedaColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        moedaIcon,
                                        color: moedaColor,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            moeda.nome,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          if (moeda.atualizadoEm != null)
                                            Text(
                                              'Atualizado em: ${formatoData.format(moeda.atualizadoEm!)}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formatoMoeda.format(moeda.valor),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: moedaColor,
                                          ),
                                        ),
                                        Text(
                                          'Valor em BRL',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '1 ${moeda.nome} = ${formatoMoeda.format(moeda.valor)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.swap_vert,
                                          size: 16,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(1/moeda.valor).toStringAsFixed(6)} BRL = 1 ${moeda.nome}',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/contas');
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.account_balance_wallet),
      ),
    );
  }

  Future<void> _atualizarCotacoes(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cotacaoService = Provider.of<CotacaoService>(context, listen: false);
      await cotacaoService.atualizarCotacoes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cotações atualizadas com sucesso!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar cotações: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}