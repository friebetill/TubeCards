import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import 'user.dart';

part 'auth_result.g.dart';

/// Result of an authentication operation like a log in or sign up.
@JsonSerializable()
@immutable
class AuthResult extends Equatable {
  const AuthResult({this.user, this.token});

  /// Constructs a new [AuthResult] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory AuthResult.fromJson(Map<String, dynamic> json) =>
      _$AuthResultFromJson(json);

  /// The [User] returned by the authentication operation.
  final User? user;

  /// The authentication [token] returned by the authentication operation.
  final String? token;

  /// Constructs a new json map from this [AuthResult].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$AuthResultToJson(this);

  @override
  List<Object?> get props => [user, token];
}
