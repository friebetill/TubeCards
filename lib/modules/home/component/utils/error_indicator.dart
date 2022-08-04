import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:logging/logging.dart';

import '../../../../graphql/operation_exception.dart';
import '../../../../i18n/i18n.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/socket_exception_extension.dart';

class ErrorIndicator extends StatefulWidget {
  const ErrorIndicator(
    this.exception, {
    Key? key,
    this.showImage = true,
  }) : super(key: key);

  final Object exception;
  final bool showImage;

  @override
  ErrorIndicatorState createState() => ErrorIndicatorState();
}

class ErrorIndicatorState extends State<ErrorIndicator> {
  final _logger = Logger((ErrorIndicator).toString());
  var _hasLoggedError = false;

  @override
  Widget build(BuildContext context) {
    if (widget.exception is OperationException) {
      if ((widget.exception as OperationException).isNoInternet) {
        return _buildNoInternetIndicator(context);
      } else if ((widget.exception as OperationException).isServerOffline) {
        return _buildServerOfflineIndicator(context);
      }
    } else if (widget.exception is SocketException) {
      if ((widget.exception as SocketException).isNoInternet) {
        return _buildNoInternetIndicator(context);
      } else if ((widget.exception as SocketException).isServerOffline) {
        return _buildServerOfflineIndicator(context);
      }
    }

    if (!_hasLoggedError) {
      _logger.severe(widget.exception);
      _hasLoggedError = true;
    }

    return Container();
  }

  Widget _buildNoInternetIndicator(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showImage)
          SvgPicture.asset(
            Assets.images.astronaut,
            height: 256,
            fit: BoxFit.fitHeight,
          ),
        if (widget.showImage) const SizedBox(height: 32),
        Text(
          S.of(context).noConnection,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).checkInternetText,
          style: Theme.of(context).textTheme.caption,
        ),
        // Add a padding of 56 to the bottom to offset the navigation bar.
        const SizedBox(height: 56),
      ],
    );
  }

  Widget _buildServerOfflineIndicator(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.showImage)
          SvgPicture.asset(
            Assets.images.maintenance,
            height: 256,
            fit: BoxFit.fitHeight,
          ),
        if (widget.showImage) const SizedBox(height: 32),
        Text(
          S.of(context).theServerTookSomeTimeOff,
          style: Theme.of(context).textTheme.bodyText2,
        ),
        const SizedBox(height: 8),
        Text(
          S.of(context).giveAnotherTryText,
          style: Theme.of(context).textTheme.caption,
        ),
        // Add a padding of 56 to the bottom to offset the navigation bar.
        const SizedBox(height: 56),
      ],
    );
  }
}
