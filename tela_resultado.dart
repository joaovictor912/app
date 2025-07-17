import 'package:flutter/material.dart';

class TelaResultado extends StatelessWidget {
  // Recebe as respostas do aluno (vindas da IA) e o gabarito mestre (do objeto Prova)
  final Map<String, String> respostasAluno;
  final Map<String, String> gabaritoMestre;
  final int totalQuestoes;

  const TelaResultado({
    super.key,
    required this.respostasAluno,
    required this.gabaritoMestre,
    required this.totalQuestoes,
  });

  // Função que faz a lógica de cálculo da nota, agora DENTRO do Flutter
  Map<String, dynamic> _calcularResultado() {
    if (gabaritoMestre.isEmpty) {
      return {'acertos': 0, 'nota': 0.0};
    }

    int acertos = 0;
    // Itera sobre o gabarito mestre para fazer a comparação
    gabaritoMestre.forEach((chaveQuestao, respostaCorreta) {
      if (respostasAluno.containsKey(chaveQuestao) && respostasAluno[chaveQuestao] == respostaCorreta) {
        acertos++;
      }
    });
    
    double nota = (acertos / gabaritoMestre.length) * 10;
    
    return {
      'acertos': acertos,
      'nota': nota,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Chama a função de cálculo antes de construir a tela
    final resultado = _calcularResultado();
    final int acertos = resultado['acertos'];
    final double nota = resultado['nota'];

    // O resto da sua UI para exibir os resultados continua o mesmo...
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado da Correção'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('NOTA', style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                Text(nota.toStringAsFixed(1), style: TextStyle(fontSize: 52, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('ACERTOS', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                Text('$acertos / ${gabaritoMestre.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Divider()),
          // Aqui você pode adicionar a lista detalhada de acertos e erros se desejar
          Expanded(
            child: Center(child: Text("Detalhes da correção aparecerão aqui.")),
          ),
        ],
      ),
    );
  }
}