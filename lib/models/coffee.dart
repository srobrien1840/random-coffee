import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'coffee.freezed.dart';
part 'coffee.g.dart';

@freezed
class Coffee with _$Coffee {
  const factory Coffee({
    required String file,
    @Default(false) bool favorite,
  }) = _Coffee;

  factory Coffee.fromJson(Map<String, Object?> json) => _$CoffeeFromJson(json);
}
