import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'connection.dart';
import 'offer.dart';

part 'user.g.dart';

/// Represents a TubeCards user.
@JsonSerializable()
@immutable
class User extends Equatable {
  /// Constructs a new [User] instance with the given parameters.
  const User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.isAnonymous,
    this.offerConnection,
  });

  /// Constructs a new [User] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// The unique id of the user.
  ///
  /// It is obtained from the server and is unique across all clients.
  final String? id;

  /// The email this user used to sign up.
  ///
  /// Each email has to be unique for a user and there can be no duplicates.
  /// For anonymous users that did not sign up, the email is set to a randomly
  /// generated, unique value.
  final String? email;

  /// First name if provided.
  final String? firstName;

  /// Last name if provided.
  final String? lastName;

  /// Whether the user is anonymous.
  ///
  /// An anonymous user did not provide any personal information
  final bool? isAnonymous;

  final Connection<Offer>? offerConnection;

  /// Constructs a new json map from this [User].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        isAnonymous,
        offerConnection,
      ];
}
