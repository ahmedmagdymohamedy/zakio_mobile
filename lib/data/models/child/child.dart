import 'package:freezed_annotation/freezed_annotation.dart';

part 'child.freezed.dart';
part 'child.g.dart';

@freezed
abstract class Child with _$Child {
  const factory Child({
    @JsonKey(name: 'id', defaultValue: "") required String id,
    @JsonKey(name: 'created_at', defaultValue: "") required String createdAt,
    @JsonKey(name: 'name', defaultValue: "") required String name,
  }) = _Child;

  factory Child.fromJson(Map<String, dynamic> json) => _$ChildFromJson(json);
}
