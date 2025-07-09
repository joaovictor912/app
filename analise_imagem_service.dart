import 'dart:convert';
import 'package:http/http.dart' as http;

class AnaliseImagemService {
  // ATENÇÃO: Verifique se o IP está correto e a porta é 5000
  final String _baseUrl = 'http://192.168.15.16:5000'; 

  Future<Map<int, String>> corrigirProva(String imagePath, int numeroDeQuestoes) async {
    // Aponta para o endpoint correto do nosso servidor Flask
    final uri = Uri.parse('$_baseUrl/analisar_prova');
    var request = http.MultipartRequest('POST', uri);
    
    // Envia os campos que o nosso servidor Flask espera
    request.fields['numeroDeQuestoes'] = numeroDeQuestoes.toString();
    request.files.add(await http.MultipartFile.fromPath('imagem', imagePath));

    try {
      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

        // Verifica se o servidor respondeu com um erro interno
        if (jsonResponse.containsKey('erro')) {
          throw Exception('Erro retornado pelo servidor: ${jsonResponse['erro']}');
        }
        
        // Converte a resposta JSON para o formato Map<int, String>
        final Map<int, String> respostas = jsonResponse.map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
        return respostas;
      } else {
        throw Exception('Falha na análise: ${streamedResponse.statusCode} - $responseBody');
      }
    } catch (e) {
      throw Exception('Erro de comunicação com o servidor: ${e.toString()}');
    }
  }
}