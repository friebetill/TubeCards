import 'package:ferry/typed_links.dart';

import '../mutations/sign_up.data.gql.dart';
import '../mutations/sign_up.var.gql.dart';
import '../queries/viewer.data.gql.dart';
import '../queries/viewer.req.gql.dart';

const String signUpHandlerKey = 'signupHandler';

void signUpHandler(
  CacheProxy proxy,
  OperationResponse<GSignUpData, GSignUpVars> response,
) {
  if (response.hasErrors) {
    return;
  }

  _updateViewerRequest(proxy, response.data!.signUp);
}

void _updateViewerRequest(
  CacheProxy proxy,
  GSignUpData_signUp signUp,
) {
  proxy.writeQuery(
    GViewerReq(),
    GViewerData((b) {
      b.viewer = GViewerData_viewer.fromJson(signUp.user.toJson())!.toBuilder();
    }),
  );
}
