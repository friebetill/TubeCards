import 'package:built_collection/built_collection.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class MarkedCardsRepository {
  MarkedCardsRepository()
      : _markedCardsIds = BehaviorSubject.seeded(BuiltList());

  final BehaviorSubject<BuiltList<String>> _markedCardsIds;

  Stream<BuiltList<String>> get() => _markedCardsIds.stream;

  void upsert(String id) {
    _markedCardsIds.add(_markedCardsIds.value.rebuild((b) {
      b
        ..removeWhere((i) => i == id)
        ..add(id);
    }));
  }

  void remove(String? id) {
    _markedCardsIds.add(_markedCardsIds.value.rebuild((b) {
      b.removeWhere((i) => i == id);
    }));
  }

  void clear() => _markedCardsIds.add(BuiltList());
}
