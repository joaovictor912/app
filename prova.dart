import 'package:json_annotation/json_annotation.dart';

part 'prova.g.dart';

@JsonSerializable()
class Prova {
  final String id;
  String nome;
  String data;
  int numeroDeQuestoes;
  Map<String, String> gabaritoOficial;

  Prova({
    required this.id,
    required this.nome,
    required this.data,
    this.numeroDeQuestoes = 20,
    Map<String, String>? gabarito,
  }) : gabaritoOficial = gabarito ?? {};

  factory Prova.fromJson(Map<String, dynamic> json) => _$ProvaFromJson(json);
  
  Map<String, dynamic> toJson() => _$ProvaToJson(this);
}