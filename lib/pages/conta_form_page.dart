
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/conta.dart';
import '../services/auth_service.dart';
import '../services/conta_service.dart';
import '../widgets/app_footer.dart';

class ContaFormPage extends StatefulWidget {
  final Conta? conta;
  final List<String> moedasDisponiveis;

  const ContaFormPage({
    Key? key,
    this.conta,
    required this.moedasDisponiveis,
  }) : super(key: key);

  @override
  _ContaFormPageState createState() => _ContaFormPageState();
}

class _ContaFormPageState extends State<ContaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _saldoController = TextEditingController();
  late String _moedaSelecionada;
  bool _isLoading = false;

  final Map<String, IconData> _moedasIcons = {
    'BRL': Icons.attach_money,
    'USD': Icons.attach_money,
    'EUR': Icons.euro,
    'GBP': Icons.currency_pound,
    'JPY': Icons.currency_yen,
    'CAD': Icons.attach_money,
    'AUD': Icons.attach_money,
    'CHF': Icons.money,
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
  void initState() {
    super.initState();
    _moedaSelecionada = widget.conta?.moeda ?? widget.moedasDisponiveis.first;

    if (widget.conta != null) {
      _nomeController.text = widget.conta!.nome;
      _saldoController.text = widget.conta!.saldoMoeda.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conta == null ? 'Nova Conta' : 'Editar Conta'),
        elevation: 0,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // O conteúdo existente permanece o mesmo
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      widget.conta == null
                                          ? Icons.add_circle
                                          : Icons.edit,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.conta == null
                                          ? 'Adicionar Nova Conta'
                                          : 'Atualizar Conta Existente',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Preencha os campos abaixo com as informações da conta. '
                                      'O saldo será convertido para BRL automaticamente.',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Nome da Conta',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            hintText: 'Ex: Conta nos EUA, Euros de viagem...',
                            prefixIcon: const Icon(Icons.account_balance),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um nome';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Moeda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                            color: Colors.white,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _moedaSelecionada,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                              hintText: 'Selecione uma moeda',
                            ),
                            items: widget.moedasDisponiveis.map((String moeda) {
                              final Color moedaColor = _moedasColors[moeda] ?? Colors.blue;
                              final IconData moedaIcon = _moedasIcons[moeda] ?? Icons.attach_money;

                              return DropdownMenuItem<String>(
                                value: moeda,
                                child: Row(
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
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      moeda,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _moedaSelecionada = newValue;
                                });
                              }
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Selecione uma moeda';
                              }
                              return null;
                            },
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                            isExpanded: true,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Saldo em $_moedaSelecionada',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _saldoController,
                          decoration: InputDecoration(
                            hintText: 'Informe o valor',
                            prefixIcon: Icon(
                              _moedasIcons[_moedaSelecionada] ?? Icons.attach_money,
                              color: _moedasColors[_moedaSelecionada],
                            ),
                            prefixText: _moedaSelecionada == 'BRL' ? 'R\$' : '',
                            suffixText: _moedaSelecionada != 'BRL' ? ' $_moedaSelecionada' : '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, insira um valor';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Por favor, insira um valor válido';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        Center(
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Cancelar'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.save),
                                  label: const Text('Salvar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _salvarConta,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Future<void> _salvarConta() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final contaService = Provider.of<ContaService>(context, listen: false);
      final auth = Provider.of<AuthService>(context, listen: false);
      final currentUser = auth.auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário não autenticado'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final saldo = double.parse(_saldoController.text);

        if (widget.conta == null) {
          final novaConta = Conta(
            nome: _nomeController.text,
            moeda: _moedaSelecionada,
            saldoMoeda: saldo,
            usuarioId: currentUser.uid,
          );
          await contaService.addConta(novaConta);
        } else {
          final contaAtualizada = widget.conta!.copyWith(
            nome: _nomeController.text,
            moeda: _moedaSelecionada,
            saldoMoeda: saldo,
          );
          await contaService.updateConta(contaAtualizada);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.conta == null
                    ? 'Conta adicionada com sucesso!'
                    : 'Conta atualizada com sucesso!',
              ),
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
              content: Text('Erro ao salvar conta: $e'),
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
}