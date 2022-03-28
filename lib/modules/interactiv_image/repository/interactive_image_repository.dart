import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class InteractiveImageRepository {
  InteractiveImageRepository();

  final isAppBarVisible = BehaviorSubject.seeded(true);

  Future<void> dispose() => isAppBarVisible.close();
}
