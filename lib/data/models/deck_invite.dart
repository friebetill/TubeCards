import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'deck.dart';
import 'role.dart';

part 'deck_invite.g.dart';

@JsonSerializable()
@CopyWith()
@immutable
class DeckInvite extends Equatable {
  /// Constructs a new [DeckInvite] instance from the given parameters.
  const DeckInvite({
    this.id,
    this.link,
    this.inviteeRole,
    this.deck,
  });

  /// Constructs a new [DeckInvite] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory DeckInvite.fromJson(Map<String, dynamic> json) =>
      _$DeckInviteFromJson(json);

  final String? id;
  final String? link;
  final Role? inviteeRole;
  final Deck? deck;

  /// Constructs a new json map from this [DeckInvite].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$DeckInviteToJson(this);

  @override
  List<Object?> get props => [id, link, inviteeRole, deck];
}
