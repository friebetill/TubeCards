import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// A model grouping together core attributes used by most model
/// implementations.
///
/// These core attributes allows for unique identification locally on the device
/// as well as on any remote storage. Furthermore it allows the model to be
/// datable regarding the time of creation and last modification. Moreover it
/// allows indication of whether any changes to the instance of the model have
/// been synchronized with the remote storage.
@immutable
abstract class BaseModel with EquatableMixin implements Identifiable, Datable {
  const BaseModel({this.id, this.createdAt, this.updatedAt});

  @override
  final String? id;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, createdAt, updatedAt];
}

/// Interface that enables unique identification locally and on a remote
/// storage.
abstract class Identifiable {
  /// The unique id used to identify a [Identifiable] locally.
  ///
  /// The id is only used in a local device context and not transferred to the
  /// backend.
  String? get id;
}

/// Interface that enables datability regarding the date of creation and last
/// modification.
abstract class Datable {
  /// [DateTime] of the creation for this [Datable].
  ///
  /// The date refers to the initial creation across all clients.
  DateTime? get createdAt;

  /// [DateTime] of the latest update to this [Datable].
  ///
  /// The date refers to the latest update up to the last synchronization
  /// across all clients.
  DateTime? get updatedAt;
}
