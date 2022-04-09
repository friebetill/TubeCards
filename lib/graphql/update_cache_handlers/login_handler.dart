import 'package:ferry/typed_links.dart';

import '../mutations/__generated__/log_in.data.gql.dart';
import '../mutations/__generated__/log_in.var.gql.dart';
import '../queries/__generated__/viewer.data.gql.dart';
import '../queries/__generated__/viewer.req.gql.dart';

const String logInHandlerKey = 'loginHandler';

void logInHandler(
  CacheProxy proxy,
  OperationResponse<GLogInData, GLogInVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  _updateViewerRequest(proxy, response.data!.login);
}

void _updateViewerRequest(
  CacheProxy proxy,
  GLogInData_login login,
) {
  proxy.writeQuery(
    GViewerReq(),
    GViewerData((b) {
      b.viewer = GViewerData_viewer.fromJson(login.user.toJson())!.toBuilder();
    }),
  );
}
