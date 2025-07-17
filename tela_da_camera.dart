import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/prova.dart';
import 'tela_exibir_foto.dart';

class TelaDaCamera extends StatefulWidget {
  final CameraDescription camera;
  final Prova prova;

  const TelaDaCamera({super.key, required this.camera, required this.prova});

  @override
  State<TelaDaCamera> createState() => _TelaDaCameraState();
}

class _TelaDaCameraState extends State<TelaDaCamera> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  FlashMode _currentFlashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    // Para garantir a melhor qualidade, definimos o foco para automático
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) return;
      _controller.setFocusMode(FocusMode.auto);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    setState(() {
      if (_currentFlashMode == FlashMode.off) {
        _currentFlashMode = FlashMode.torch; // Alterna direto para "Sempre Ligado"
      } else {
        _currentFlashMode = FlashMode.off;
      }
      _controller.setFlashMode(_currentFlashMode);
    });
  }

  IconData _getFlashIcon() {
    return _currentFlashMode == FlashMode.torch ? Icons.flash_on : Icons.flash_off;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alinhe o Gabarito'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // A Câmera ocupa todo o espaço
                CameraPreview(_controller),
                // O Guia de Alinhamento sobreposto à câmera
                _buildOverlayGuide(),
                // A Barra de Controles na parte inferior
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildControlBar(),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  // Widget que constrói o guia de alinhamento
  Widget _buildOverlayGuide() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define as dimensões do recorte central com base no tamanho da tela
        double rectWidth = constraints.maxWidth * 0.9; // 90% da largura da tela
        double rectHeight = constraints.maxHeight * 0.8; // 80% da altura da tela

        return Stack(
          children: [
            // Camada escura semi-transparente sobre toda a tela
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.5),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  // Fundo que será "recortado"
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                  ),
                  // O retângulo central que ficará claro
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: rectWidth,
                      height: rectHeight,
                      decoration: BoxDecoration(
                        color: Colors.black, // A cor aqui não importa, será recortada
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // A borda branca do guia
            Align(
              alignment: Alignment.center,
              child: Container(
                width: rectWidth,
                height: rectHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
             // Texto de instrução
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 40.0),
                child: Text(
                  'Posicione o gabarito dentro da moldura',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget que constrói a barra de controles
  Widget _buildControlBar() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(_getFlashIcon(), color: Colors.white, size: 30),
            onPressed: _toggleFlash,
          ),
          FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                if (!mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TelaExibirFoto(imagePath: image.path, prova: widget.prova),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }
}
