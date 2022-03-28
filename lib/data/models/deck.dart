import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'base_model.dart';
import 'card.dart';
import 'connection.dart';
import 'deck_invite.dart';
import 'deck_member.dart';
import 'offer.dart';
import 'unsplash_image.dart';
import 'user.dart';

part 'deck.g.dart';

/// Represents a deck which is a collection of cards.
///
/// A deck is a user-created entity and designed to be based around one core
/// topic like 'Physics' or 'Spanish'.
@JsonSerializable()
@CopyWith()
class Deck extends BaseModel {
  /// Constructs a new [Deck] instance from the given parameters.
  const Deck({
    String? id,
    this.name,
    this.description,
    this.coverImage,
    this.frontLanguage,
    this.backLanguage,
    this.createMirrorCard,
    this.creator,
    this.cardConnection,
    this.dueCardConnection,
    this.viewerDeckMember,
    this.deckMemberConnection,
    this.deckInvites,
    this.offer,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Constructs a new [Deck] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory Deck.fromJson(Map<String, dynamic> json) => _$DeckFromJson(json);

  /// The name of the deck.
  final String? name;

  /// The description of the deck.
  final String? description;

  /// The [UnsplashImage] used as the cover image of the deck.
  final UnsplashImage? coverImage;

  /// ISO 639-1 (2 digits) language code for the language used on the front
  /// of the cards.
  ///
  /// This assumes that a deck will stay consistent regarding language usage
  /// on the sides of the cards.
  final String? frontLanguage;

  /// ISO 639-1 (2 digits) language code for the language used on the back of
  /// the cards.
  ///
  /// This assumes that a deck will stay consistent regarding language usage
  /// on the sides of the cards.
  final String? backLanguage;

  /// Indicates whether a mirror card should be created for each new card.
  ///
  /// These are used for bidirectional learning. The mirror card contains the
  /// same data as the original card but in reversed order (front is on back
  /// and vice versa).
  @JsonKey(defaultValue: false)
  final bool? createMirrorCard;

  final User? creator;

  final Connection<Card>? dueCardConnection;

  final Connection<Card>? cardConnection;

  final DeckMember? viewerDeckMember;

  final Connection<DeckMember>? deckMemberConnection;

  final List<DeckInvite>? deckInvites;

  final Offer? offer;

  /// Constructs a new json map from this [Deck].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$DeckToJson(this);

  @override
  List<Object?> get props => super.props
    ..addAll([
      name,
      description,
      coverImage,
      frontLanguage,
      backLanguage,
      createMirrorCard,
      creator,
      cardConnection,
      dueCardConnection,
      viewerDeckMember,
      deckMemberConnection,
      deckInvites,
      offer,
    ]);
}
