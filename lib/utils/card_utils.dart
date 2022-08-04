const _pictureEmoji = '🖼️';

/// Returns a textual preview of this card.
///
/// The preview only consists of the front text and might not show the full
/// text.
String getPreview(String text) {
  // _replaceMarkdownImages must be called before _removeURLFromMarkdownLinks,
  // because _removeURLFromMarkdownLinks use a regular expression that is a
  // superset of the regular expression used in _replaceMarkdownImages.
  var preview = _replaceMarkdownImages(text);
  preview = _replaceMarkdownLinks(preview);

  // Skips empty lines and all Markdown line formatting.
  final alphaNumStart =
      preview.indexOf(RegExp('[^\n^#^ ^>^-^(1-9.)^((?!* |+ |\\- ).)^`]'));
  if (alphaNumStart != -1) {
    preview = preview.substring(alphaNumStart);
  }

  return preview;
}

/// Replaces all markdown images in the given [content] with [replacement].
///
/// By default, all images will be replaced by an image emoji.
String _replaceMarkdownImages(
  String content, [
  String replacement = _pictureEmoji,
]) {
  final markdownImageRegExp = RegExp(r'!\[(.*)\]\((.+)\)');

  return content.replaceAll(markdownImageRegExp, replacement);
}

/// Replaces all markdown links in the given [content] with the visible part
/// of the respective link.
String _replaceMarkdownLinks(String content) {
  final markdownLinkRegExp = RegExp(r'\[(.*)\]\((.+)\)');

  return content.replaceAllMapped(markdownLinkRegExp, (m) => m.group(1)!);
}
