class Moeda {
  final String nome;
  final double valor;

  Moeda({required this.nome, required this.valor});

  factory Moeda.fromJson(Map<String, dynamic> json) {
    return Moeda(
      nome: json['code'],
      valor: json['bid'],
    );
  }
}