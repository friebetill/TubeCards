import 'package:ferry/ferry.dart';
import 'package:ferry_hive_store/ferry_hive_store.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../graph_ql_client.dart';
import '../../graph_ql_runner.dart';

const String databasePathKey = 'database_path';
const String portKey = 'port';

@Environment('graphql_main')
@Singleton(as: GraphQLRunner)
class GraphQLMainRunner implements GraphQLRunner {
  late GraphQLClient _client;

  @override
  Future<void> spawn() async {
    Hive.init((await getApplicationDocumentsDirectory()).path);

    _client = GraphQLClient(Cache(
      store: HiveStore(await Hive.openBox(GraphQLClient.graphQLHiveBoxName)),
      typePolicies: GraphQLClient.typePolicies,
    ));
  }

  @override
  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) {
    return _client.request(request);
  }

  @override
  Future<void> clear() async {
    _client
      ..authToken = ''
      ..clear();
  }

  @override
  Future<void> setAuthToken(String token) async => _client.authToken = token;

  @override
  Future<bool> isLoggedIn() async => _client.authToken != '';
}
