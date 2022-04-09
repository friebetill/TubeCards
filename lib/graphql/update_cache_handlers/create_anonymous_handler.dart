import 'package:ferry/typed_links.dart';

import '../mutations/__generated__/create_anonymous_user.data.gql.dart';
import '../mutations/__generated__/create_anonymous_user.var.gql.dart';
import '../queries/__generated__/viewer.data.gql.dart';
import '../queries/__generated__/viewer.req.gql.dart';

const String createAnonymousUserHandlerKey = 'createAnonymousUserHandler';

void createAnonymousUserHandler(
  CacheProxy proxy,
  OperationResponse<GCreateAnonymousUserData, GCreateAnonymousUserVars>
      response,
) {
  if (response.hasErrors) {
    return;
  }

  _updateViewerRequest(proxy, response.data!.createAnonymousUser);
}

void _updateViewerRequest(
  CacheProxy proxy,
  GCreateAnonymousUserData_createAnonymousUser createAnonymousUser,
) {
  proxy.writeQuery(
    GViewerReq(),
    GViewerData((b) {
      b.viewer = GViewerData_viewer.fromJson(
        createAnonymousUser.user.toJson(),
      )!
          .toBuilder();
    }),
  );
}
