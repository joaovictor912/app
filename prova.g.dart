// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prova.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prova _$ProvaFromJson(Map<String, dynamic> json) => Prova(
  id: json['id'] as String,
  nome: json['nome'] as String,
  data: json['data'] as String,
  numeroDeQuestoes: (json['numeroDeQuestoes'] as num?)?.toInt() ?? 20,
)..gabaritoOficial = Map<String, String>.from(json['gabaritoOficial'] as Map);

Map<String, dynamic> _$ProvaToJson(Prova instance) => <String, dynamic>{
  'id': instance.id,
  'nome': instance.nome,
  'data': instance.data,
  'numeroDeQuestoes': instance.numeroDeQuestoes,
  'gabaritoOficial': instance.gabaritoOficial,
};
