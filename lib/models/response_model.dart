import 'package:freezed_annotation/freezed_annotation.dart';

part 'response_model.freezed.dart';

@freezed
class ResponseModel with _$ResponseModel {
  const factory ResponseModel({
    required String? error,
    required dynamic data,
  }) = _ResponseModel;
}
