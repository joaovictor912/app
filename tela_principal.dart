import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/turma.dart';
import 'tela_da_turma.dart';
import '../services/persistencia_service.dart';

class TelaPrincipal extends StatefulWidget {
  final CameraDescription camera;
  const TelaPrincipal({super.key, required this.camera});

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  List<Turma> _turmas = [];
  bool _isLoading = true;
  final PersistenciaService _persistenciaService = PersistenciaService();

  @override
  void initState() {
    super.initState();
    // Ao iniciar a tela, carregamos as turmas salvas do disco.
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final turmasSalvas = await _persistenciaService.carregarTurmas();
    // Usamos setState para atualizar a tela com os dados carregados.
    setState(() {
      _turmas = turmasSalvas;
      _isLoading = false;
    });
  }

  // Função para salvar a lista atual de turmas no disco.
  Future<void> _salvarDados() async {
    // Adicionamos um print para podermos ver quando o salvamento é chamado
    print("Salvando dados de todas as turmas...");
    await _persistenciaService.salvarTurmas(_turmas);
    print("Dados salvos com sucesso!");
  }

  void _mostrarDialogoTurma({Turma? turmaExistente}) {
    final bool isEditing = turmaExistente != null;
    final TextEditingController nomeController =
        TextEditingController(text: isEditing ? turmaExistente.nome : '');
    final TextEditingController alunosController = TextEditingController(
        text: isEditing ? turmaExistente.numeroDeAlunos.toString() : '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Turma' : 'Nova Turma'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: nomeController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Nome da Turma'),
            ),
            TextField(
              controller: alunosController,
              decoration: const InputDecoration(labelText: 'Nº de Alunos'),
              keyboardType: TextInputType.number,
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final nome = nomeController.text;
                final numeroDeAlunos = int.tryParse(alunosController.text) ?? 0;
                if (nome.isNotEmpty) {
                  setState(() {
                    if (isEditing) {
                      turmaExistente.nome = nome;
                      turmaExistente.numeroDeAlunos = numeroDeAlunos;
                    } else {
                      _turmas.add(Turma(
                        id: DateTime.now().toString(),
                        nome: nome,
                        numeroDeAlunos: numeroDeAlunos,
                        provas: [],
                      ));
                    }
                  });
                  // SALVA OS DADOS APÓS QUALQUER MUDANÇA
                  _salvarDados(); 
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Turmas'), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _turmas.isEmpty // Adiciona uma mensagem se a lista estiver vazia
              ? const Center(
                  child: Text(
                    'Nenhuma turma cadastrada.\nClique no botão + para adicionar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _turmas.length,
                  itemBuilder: (context, index) {
                    final turma = _turmas[index];
                    // O Dismissible é o widget que implementa a função de deletar
                    return Dismissible(
                      key: Key(turma.id),
                      direction: DismissDirection.endToStart, // Arrastar da direita para a esquerda
                      background: Container(
                        color: Colors.redAccent,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: const Icon(Icons.delete_sweep, color: Colors.white),
                      ),
                      // Ação que acontece quando o item é arrastado
                      onDismissed: (direction) {
                        final turmaRemovida = _turmas[index];
                        setState(() {
                          _turmas.removeAt(index);
                        });
                        // SALVA OS DADOS APÓS REMOVER
                        _salvarDados(); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${turmaRemovida.nome} removida')),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(turma.nome.substring(0, 1))),
                          title: Text(turma.nome),
                          subtitle: Text('${turma.numeroDeAlunos} alunos • ${turma.provas.length} provas'),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _mostrarDialogoTurma(turmaExistente: turma),
                          ),
                          onTap: () {
                            // --- MUDANÇA PRINCIPAL AQUI ---
                            // Agora, ao navegar para a TelaDaTurma, passamos a função _salvarDados
                            // para o parâmetro onDadosAlterados.
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TelaDaTurma(
                                turma: turma, 
                                camera: widget.camera,
                                onDadosAlterados: _salvarDados, // Passando a função de callback
                              )
                            ));
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoTurma,
        tooltip: 'Adicionar Turma',
        child: const Icon(Icons.add),
      ),
    );
  }
}