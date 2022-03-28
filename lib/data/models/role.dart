import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../i18n/i18n.dart';
import '../../utils/permission.dart';

part 'role.g.dart';

@JsonSerializable()
@CopyWith()
@immutable
class Role extends Equatable {
  /// Constructs a new [Role] instance from the given parameters.
  const Role({required this.id})
      : assert(
          id == _ownerId ||
              id == _editorId ||
              id == _viewerId ||
              id == _subscriberId,
        );

  /// Constructs a new [Role] from the given [json].
  ///
  /// A conversion from JSON is especially useful in order to handle results
  /// from a server request.
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  static const Role owner = Role(id: _ownerId);
  static const Role editor = Role(id: _editorId);
  static const Role viewer = Role(id: _viewerId);
  static const Role subscriber = Role(id: _subscriberId);

  static const _ownerId = 'OWNER';
  static const _editorId = 'EDITOR';
  static const _viewerId = 'VIEWER';
  static const _subscriberId = 'SUBSCRIBER';

  final String? id;

  /// Constructs a new json map from this [Role].
  ///
  /// A conversion to JSON is useful in order to send data to a server.
  Map<String, dynamic> toJson() => _$RoleToJson(this);

  @override
  List<Object?> get props => [id];

  bool hasPermission(Permission permission) {
    if (id == _ownerId) {
      return _ownerPermissions.contains(permission);
    } else if (id == _editorId) {
      return _editorPermissions.contains(permission);
    } else if (id == _viewerId) {
      return _viewerPermissions.contains(permission);
    } else if (id == _subscriberId) {
      return _subscriberPermissions.contains(permission);
    } else {
      return false;
    }
  }

  String toDisplayTitle(BuildContext context) {
    switch (id) {
      case _ownerId:
        return S.of(context).owner;
      case _editorId:
        return S.of(context).editor;
      case _viewerId:
        return S.of(context).viewer;
      case _subscriberId:
        return S.of(context).subscriber;
      default:
        return S.of(context).unknown;
    }
  }

  static const _ownerPermissions = [
    Permission.cardDelete,
    Permission.cardGet,
    Permission.cardUpsert,
    Permission.deckDelete,
    Permission.deckGet,
    Permission.deckMemberDelete,
    Permission.deckMemberGet,
    Permission.deckMemberUpdateOther,
    Permission.deckMemberUpdateSelf,
    Permission.deckUpdate,
    Permission.editorLinkUpsert,
    Permission.editorLinkView,
    Permission.offerAdd,
    Permission.offerDelete,
    Permission.repetitionAdd,
    Permission.viewerLinkUpsert,
    Permission.viewerLinkView,
  ];

  static const _editorPermissions = [
    Permission.cardDelete,
    Permission.cardGet,
    Permission.cardUpsert,
    Permission.deckGet,
    Permission.deckMemberGet,
    Permission.deckMemberUpdateSelf,
    Permission.editorLinkView,
    Permission.offerReviewAdd,
    Permission.repetitionAdd,
    Permission.viewerLinkView,
  ];

  static const _viewerPermissions = [
    Permission.cardGet,
    Permission.deckGet,
    Permission.deckMemberGet,
    Permission.deckMemberUpdateSelf,
    Permission.offerReviewAdd,
    Permission.repetitionAdd,
    Permission.viewerLinkView,
  ];

  static const _subscriberPermissions = [
    Permission.cardGet,
    Permission.deckGet,
    Permission.offerReviewAdd,
    Permission.repetitionAdd,
  ];
}
