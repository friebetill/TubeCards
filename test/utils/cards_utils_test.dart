import 'package:client_mobile/utils/card_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Skips empty lines up to the first character', () {
    const markdown = '''

Test''';

    final result = getPreview(markdown);

    expect(result, equals('Test'));
  });

  test('Replace images with image emojis ', () {
    const markdown = '![alt text](Isolated.png "Title")';

    final result = getPreview(markdown);

    expect(result, equals('🖼️'));
  });

  test("Doesn't remove umlaute", () {
    const markdown = 'Älterer Bruder';

    final result = getPreview(markdown);

    expect(result, equals('Älterer Bruder'));
  });

  test("Doesn't remove chinese symbols", () {
    const markdown = '汉字Test';

    final result = getPreview(markdown);

    expect(result, equals('汉字Test'));
  });
}
