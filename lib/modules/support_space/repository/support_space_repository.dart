import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rxdart/rxdart.dart';

@singleton
class SupportSpaceRepository {
  SupportSpaceRepository();

  // ignore: close_sinks
  final purchaserInfo = BehaviorSubject<PurchaserInfo>();
}
