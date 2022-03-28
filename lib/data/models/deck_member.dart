import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import 'deck.dart';
import 'role.dart';
import 'user.dart';

part 'deck_member.g.dart';

@JsonSerializable()
@CopyWith()
@immutable
class DeckMember extends Equatable {
  /// Constructs a new [DeckMember] instance from the given parameters.
  const DeckMember({this.role, this.user, this.deck, this.isActive});

  /// Constructs a new [DeckMember] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory DeckMember.fromJson(Map<String, dynamic> json) =>
      _$DeckMemberFromJson(json);

  final Role? role;
  final User? user;
  final Deck? deck;
  final bool? isActive;

  /// Constructs a new json map from this [DeckMember].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$DeckMemberToJson(this);

  @override
  List<Object?> get props => [role, user, deck, isActive];
}
