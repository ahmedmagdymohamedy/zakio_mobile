// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Child _$ChildFromJson(Map<String, dynamic> json) => _Child(
  id: json['id'] as String? ?? '',
  createdAt: json['created_at'] as String? ?? '',
  name: json['name'] as String? ?? '',
);

Map<String, dynamic> _$ChildToJson(_Child instance) => <String, dynamic>{
  'id': instance.id,
  'created_at': instance.createdAt,
  'name': instance.name,
};
