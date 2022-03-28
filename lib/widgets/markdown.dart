import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';

import '../main.dart';

Widget buildMedia({required String url, VoidCallback? onImageTap}) {
  return url.endsWith('mp4')
      ? _MarkdownVideo(url: url, onImageTap: onImageTap)
      : _buildImage(url: url, onImageTap: onImageTap);
}

class _MarkdownVideo extends StatefulWidget {
  const _MarkdownVideo({
    required this.url,
    required this.onImageTap,
    Key? key,
  }) : super(key: key);

  final String url;
  final VoidCallback? onImageTap;

  @override
  _MarkdownVideoState createState() => _MarkdownVideoState();
}

class _MarkdownVideoState extends State<_MarkdownVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    final canDisplayVideos = Platform.isAndroid || Platform.isIOS;
    if (canDisplayVideos) {
      _controller = VideoPlayerController.network(widget.url)
        ..setLooping(true)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized,
          // even before the play button has been pressed.
          setState(() {});
        })
        ..play();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Container();
    }

    return SizedBox(
      width: double.infinity,
      height: 236,
      child: Center(
        child: _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : const SizedBox(
                height: 32,
                width: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

Widget _buildImage({required String url, VoidCallback? onImageTap}) {
  return SizedBox(
    width: double.infinity,
    child: FutureBuilder<File>(
      key: ValueKey(url),
      future: getIt<BaseCacheManager>().getSingleFile(url),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Icon(Icons.error_outline);
        }
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              height: 32,
              width: 32,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }

        return GestureDetector(
          onTap: onImageTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Hero(
              tag: '$url-hero',
              child: Container(
                // Always color the SVG background white, even in dark mode.
                color: Colors.white,
                child: url.endsWith('svg')
                    ? SvgPicture.file(snapshot.data!)
                    : Image.file(snapshot.data!, fit: BoxFit.contain),
              ),
            ),
          ),
        );
      },
    ),
  );
}

MarkdownStyleSheet buildStyleSheet(BuildContext context) {
  final paragraphStyle =
      Theme.of(context).textTheme.bodyText2!.copyWith(height: 1.3);

  return MarkdownStyleSheet(
    p: paragraphStyle,
    a: paragraphStyle.copyWith(color: Theme.of(context).colorScheme.primary),
  );
}
