
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/conta.dart';
import '../services/auth_service.dart';
import '../services/conta_service.dart';
import '../widgets/app_footer.dart';
import 'conta_form_page.dart';

class ListaContasPage extends StatefulWidget {
  const ListaContasPage({Key? key}) : super(key: key);

  @override
  _ListaContasPageState createState() => _ListaContasPageState();
}

class _ListaContasPageState extends State<ListaContasPage> {
  final formatoMoeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final formatoCotacao = NumberFormat('0.000000');
  bool _isLoading = false;

  final List<String> _moedasDisponiveis = [
    'BRL', 'USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'CHF'
  ];

  final Map<String, IconData> _moedasIcons = {
    'BRL': Icons.attach_money,
    'USD': Icons.attach_money,
    'EUR': Icons.euro_symbol,
    'GBP': Icons.currency_pound,
    'JPY': Icons.currency_yen,
    'CAD': Icons.monetization_on,
    'AUD': Icons.monetization_on,
    'CHF': Icons.monetization_on,
  };

  final Map<String, Color> _moedasColors = {
    'BRL': Colors.green,
    'USD': Colors.blue,
    'EUR': Colors.indigo,
    'GBP': Colors.purple,
    'JPY': Colors.red,
    'CAD': Colors.orange,
    'AUD': Colors.amber.shade800,
    'CHF': Colors.teal,
  };

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final contaService = Provider.of<ContaService>(context);

    final currentUser = authService.auth.currentUser;
    if (currentUser == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Contas'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Menu principal',
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar saldos',
            onPressed: () {
              _atualizarSaldos(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () async {
              await authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
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
                    icon: const Icon(Icons.currency_exchange),
                    label: const Text('Ver Cotações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/cotacoes');
                    },
                  ),
                  const Spacer(),
                  if (_isLoading)
                    const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)
                    ),
                ],
              ),
            ),

            const Divider(),

            StreamBuilder<List<Conta>>(
              stream: contaService.getContas(currentUser.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                final contas = snapshot.data ?? [];
                final totalBRL = contas.fold(0.0, (sum, conta) => sum + conta.saldoBRL);

                return Card(
                  margin: const EdgeInsets.all(16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Saldo Total (BRL)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatoMoeda.format(totalBRL),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${contas.length} ${contas.length == 1 ? 'conta' : 'contas'} registradas',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Expanded(
              child: StreamBuilder<List<Conta>>(
                stream: contaService.getContas(currentUser.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar contas: ${snapshot.error}'),
                    );
                  }

                  final contas = snapshot.data ?? [];
                  if (contas.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 64,
                            color: Colors.black26,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Você não possui contas cadastradas',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContaFormPage(
                                    moedasDisponiveis: _moedasDisponiveis,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Adicionar Conta'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: contas.length,
                    itemBuilder: (context, index) {
                      final conta = contas[index];
                      return _buildContaCard(context, conta);
                    },
                  );
                },
              ),
            ),

            const AppFooter(), // AppFooter adicionado aqui
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContaFormPage(
                moedasDisponiveis: _moedasDisponiveis,
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Conta'),
        backgroundColor: Colors.blue,
      ),
    );
  }


  Widget _buildContaCard(BuildContext context, Conta conta) {
    final bool isReais = conta.moeda == 'BRL';
    final Color moedaColor = _moedasColors[conta.moeda] ?? Colors.blue;
    final IconData moedaIcon = _moedasIcons[conta.moeda] ?? Icons.attach_money;

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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContaFormPage(
                conta: conta,
                moedasDisponiveis: _moedasDisponiveis,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: moedaColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      moedaIcon,
                      color: moedaColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conta.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          conta.moeda,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'editar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContaFormPage(
                              conta: conta,
                              moedasDisponiveis: _moedasDisponiveis,
                            ),
                          ),
                        );
                      } else if (value == 'excluir') {
                        _confirmarExclusao(context, conta);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'excluir',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saldo ${conta.moeda}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReais
                            ? formatoMoeda.format(conta.saldoMoeda)
                            : '${conta.moeda} ${NumberFormat.decimalPattern().format(conta.saldoMoeda)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (!isReais)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Valor em BRL',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatoMoeda.format(conta.saldoBRL),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (!isReais && conta.taxaConversao > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Taxa: 1 ${conta.moeda} = ${formatoMoeda.format(conta.taxaConversao)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (conta.ultimaAtualizacao != null)
                        Text(
                          'Atualizado em: ${DateFormat('dd/MM/yy HH:mm').format(conta.ultimaAtualizacao!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, Conta conta) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a conta "${conta.nome}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              setState(() {
                _isLoading = true;
              });

              try {
                final contaService = Provider.of<ContaService>(context, listen: false);
                await contaService.deleteConta(conta.id!);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Conta excluída com sucesso!'),
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
                      content: Text('Erro ao excluir conta: $e'),
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _atualizarSaldos(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final contaService = Provider.of<ContaService>(context, listen: false);
      await contaService.atualizarTodasCotacoes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Saldos atualizados com sucesso!'),
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
            content: Text('Erro ao atualizar saldos: $e'),
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