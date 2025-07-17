import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class AnaliseImagemService {
  
  final String _baseUrl = 'http://192.168.15.16:5000'; 

  Future<Map<String, String>> analisarImagem(File imagem) async {
    final uri = Uri.parse('$_baseUrl/analisar_prova');
    var request = http.MultipartRequest('POST', uri);
    
    request.files.add(await http.MultipartFile.fromPath('imagem', imagem.path));

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final jsonResponse = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 200) {
        if (jsonResponse.containsKey('erro')) {
          throw Exception('Erro no servidor: ${jsonResponse['erro']}');
        }
        return jsonResponse.map((key, value) => MapEntry(key, value.toString()));
      } else {
        throw Exception('Falha na análise: ${jsonResponse['erro']}');
      }
    } catch (e) {
      throw Exception('Erro de comunicação com o servidor: ${e.toString()}');
    }
  }
}