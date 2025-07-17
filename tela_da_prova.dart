import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../models/prova.dart';
import 'tela_da_camera.dart';

class TelaDaProva extends StatelessWidget {
  final Prova prova;
  final CameraDescription camera;

  const TelaDaProva({super.key, required this.prova, required this.camera});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(prova.nome), backgroundColor: Theme.of(context).colorScheme.inversePrimary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Pronto para corrigir?', style: TextStyle(fontSize: 22)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.deepPurple, foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Corrigir com a Câmera'),
              onPressed: () {
                Navigator.push(
                  context,
                  // MUDANÇA AQUI: Passamos o objeto 'prova' para a TelaDaCamera
                  MaterialPageRoute(builder: (context) => TelaDaCamera(camera: camera, prova: prova)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}