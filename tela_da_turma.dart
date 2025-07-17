import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/prova.dart';
import '../models/turma.dart';
import 'tela_da_prova.dart';
import 'tela_gabarito_mestre.dart';

class TelaDaTurma extends StatefulWidget {
  final Turma turma;
  final CameraDescription camera;
  // MUDANÇA 1: Adicionamos uma função de callback.
  // Esta função será chamada para notificar a tela anterior que os dados precisam ser salvos.
  final VoidCallback onDadosAlterados;

  const TelaDaTurma({
    super.key,
    required this.turma,
    required this.camera,
    required this.onDadosAlterados, // MUDANÇA 2: Tornamos o callback obrigatório.
  });

  @override
  State<TelaDaTurma> createState() => _TelaDaTurmaState();
}

class _TelaDaTurmaState extends State<TelaDaTurma> {
  void _mostrarDialogoNovaProva() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController questoesController = TextEditingController();
    DateTime dataSelecionada = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Nova Prova'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nomeController,
                    autofocus: true,
                    decoration: const InputDecoration(labelText: 'Nome da Prova'),
                  ),
                  TextField(
                    controller: questoesController,
                    decoration: const InputDecoration(labelText: 'Nº de Questões'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Data: '),
                      Text(
                        DateFormat('dd/MM/yyyy').format(dataSelecionada),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final DateTime? dataEscolhida = await showDatePicker(
                            context: context,
                            initialDate: dataSelecionada,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (dataEscolhida != null) {
                            setDialogState(() {
                              dataSelecionada = dataEscolhida;
                            });
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nomeController.text.isNotEmpty) {
                      final int numeroDeQuestoes =
                          int.tryParse(questoesController.text) ?? 20;

                      setState(() {
                        widget.turma.provas.add(
                          Prova(
                            id: DateTime.now().toString(),
                            nome: nomeController.text,
                            data: DateFormat('dd/MM/yyyy').format(dataSelecionada),
                            numeroDeQuestoes: numeroDeQuestoes,
                          ),
                        );
                      });

                      // MUDANÇA 3 (A MAIS IMPORTANTE): Chamamos a função de callback
                      // para avisar a tela principal que precisa salvar.
                      widget.onDadosAlterados();

                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.turma.nome),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: widget.turma.provas.length,
        itemBuilder: (context, index) {
          final prova = widget.turma.provas[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.assignment, color: Color.fromARGB(255, 20, 12, 133)),
              title: Text(prova.nome),
              subtitle: Text('Questões: ${prova.numeroDeQuestoes} • Data: ${prova.data}'),
              trailing: IconButton(
                icon: const Icon(Icons.playlist_add_check, color: Colors.grey),
                tooltip: 'Editar Gabarito',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // MUDANÇA 4: Passamos o callback também para a tela de gabarito.
                      builder: (context) => TelaGabaritoMestre(
                        prova: prova,
                        onGabaritoSalvo: widget.onDadosAlterados,
                      ),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TelaDaProva(prova: prova, camera: widget.camera)),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoNovaProva,
        label: const Text('Nova Prova'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}