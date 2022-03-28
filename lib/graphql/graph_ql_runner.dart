import 'package:ferry/ferry.dart';

abstract class GraphQLRunner {
  /// Initializes the runner.
  ///
  /// Call this method before calling any other method. Calling the method
  /// multiple times has no effect.
  Future<void> spawn();

  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request,
  );

  Future<void> setAuthToken(String token);

  Future<bool> isLoggedIn();

  /// Deletes all data on the GraphQL database.
  Future<void> clear();
}
