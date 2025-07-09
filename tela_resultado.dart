import 'package:flutter/material.dart';

class TelaResultado extends StatelessWidget {
  final Map<int, String> respostasAluno;
  final Map<String, String> gabaritoMestre;
  final int totalQuestoes;

  const TelaResultado({
    super.key,
    required this.respostasAluno,
    required this.gabaritoMestre,
    required this.totalQuestoes,
  });

  // Função para calcular os acertos e a nota
  Map<String, dynamic> _calcularResultado() {
    int acertos = 0;
    for (int i = 1; i <= totalQuestoes; i++) {
      String chaveGabarito = i.toString();
      if (respostasAluno.containsKey(i) &&
          gabaritoMestre.containsKey(chaveGabarito) &&
          respostasAluno[i] == gabaritoMestre[chaveGabarito]) {
        acertos++;
      }
    }
    double nota = (totalQuestoes > 0) ? (acertos / totalQuestoes) * 10 : 0.0;
    
    return {
      'acertos': acertos,
      'nota': nota,
    };
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _calcularResultado();
    final int acertos = resultado['acertos'];
    final double nota = resultado['nota'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Correção'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Seção do topo com a NOTA e os ACERTOS
          Container(
            padding: const EdgeInsets.all(24.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NOTA',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                ),
                Text(
                  nota.toStringAsFixed(1),
                  style: TextStyle(fontSize: 52, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'ACERTOS',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                Text(
                  '$acertos / $totalQuestoes',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(),
          ),
          
          // Lista rolável com o detalhamento das questões
          Expanded(
            child: ListView.builder(
              itemCount: totalQuestoes,
              itemBuilder: (context, index) {
                final int numeroQuestao = index + 1;
                final String chaveGabarito = numeroQuestao.toString();

                final String respostaCorreta = gabaritoMestre[chaveGabarito] ?? '-';
                final String respostaAluno = respostasAluno[numeroQuestao] ?? '-';
                final bool acertou = respostaCorreta == respostaAluno && respostaAluno != '-';

                return Card(
                  color: acertou ? Colors.green.shade50 : Colors.red.shade50,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: acertou ? Colors.green : Colors.red,
                      child: Icon(acertou ? Icons.check : Icons.close, color: Colors.white),
                    ),
                    title: Text('Questão $numeroQuestao', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Sua Resposta: $respostaAluno • Gabarito: $respostaCorreta'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}