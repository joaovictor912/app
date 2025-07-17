import 'dart:io';
import 'package:flutter/material.dart';
import '../models/prova.dart';
import '../services/analise_imagem_service.dart';
import 'tela_resultado.dart';

class TelaExibirFoto extends StatefulWidget {
  final String imagePath;
  final Prova prova;
  const TelaExibirFoto({super.key, required this.imagePath, required this.prova});

  @override
  State<TelaExibirFoto> createState() => _TelaExibirFotoState();
}

class _TelaExibirFotoState extends State<TelaExibirFoto> {
  bool _isProcessing = false;

  Future<void> _analisarEObterResultado() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final analiseService = AnaliseImagemService();
      // 1. O serviço agora só precisa da imagem
      final Map<String, String> respostasDoAluno = await analiseService.analisarImagem(File(widget.imagePath));

      if (!mounted) return;
      
      // 2. A lógica de cálculo da nota acontece aqui, no Flutter
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaResultado(
            respostasAluno: respostasDoAluno,
            gabaritoMestre: widget.prova.gabaritoOficial,
            totalQuestoes: widget.prova.numeroDeQuestoes,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro na análise: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
  
  // O seu widget build continua o mesmo...
  @override
  Widget build(BuildContext context) {
    // ... (cole o seu widget build aqui, ele não precisa de mudanças)
    return Scaffold(
      appBar: AppBar(title: const Text('Verifique a Foto')),
      body: Stack(fit: StackFit.expand, children: [
        Image.file(File(widget.imagePath), fit: BoxFit.contain),
        if (_isProcessing)
          Container(
            color: Colors.black.withOpacity(0.7),
            child: const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text('Analisando gabarito...', style: TextStyle(color: Colors.white, fontSize: 18, decoration: TextDecoration.none)),
            ],),),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _analisarEObterResultado,
        label: _isProcessing ? const Text("Aguarde...") : const Text("Corrigir Prova"),
        icon: _isProcessing ? const SizedBox.shrink() : const Icon(Icons.check_circle),
      ),
    );
  }
}