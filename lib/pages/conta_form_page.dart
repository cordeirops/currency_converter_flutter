import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/conta.dart';
import '../services/auth_service.dart';
import '../services/conta_service.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conta == null ? 'Nova Conta' : 'Editar Conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Conta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _moedaSelecionada,
                items: widget.moedasDisponiveis.map((String moeda) {
                  return DropdownMenuItem<String>(
                    value: moeda,
                    child: Text(moeda),
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
                decoration: const InputDecoration(
                  labelText: 'Moeda',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _saldoController,
                decoration: InputDecoration(
                  labelText: 'Saldo em $_moedaSelecionada',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvarConta,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvarConta() async {
    if (_formKey.currentState?.validate() ?? false) {
      final contaService = Provider.of<ContaService>(context, listen: false);
      final auth = Provider.of<AuthService>(context, listen: false);
      final currentUser = auth.auth.currentUser;

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado')),
        );
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

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar conta: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _saldoController.dispose();
    super.dispose();
  }
}