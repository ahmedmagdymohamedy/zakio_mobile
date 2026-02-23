// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Child _$ChildFromJson(Map<String, dynamic> json) => _Child(
  id: (json['id'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? DateTime.now()
      : DateTime.parse(json['created_at'] as String),
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$ChildToJson(_Child instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt.toIso8601String(),
  'name': instance.name,
};
