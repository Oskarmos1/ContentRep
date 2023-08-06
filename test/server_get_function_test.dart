import 'package:daily/backend/backend_classes/content.dart';
import 'package:daily/backend/backend_classes/server_get_functions.dart';
import 'package:test/test.dart';

void main() {
  test('Should return 8 values', () {
    final sGF = ServerGetFunctions();
    List<Content> allContent = [];
    for (int i = 0; i <= 8; i++) {
      allContent.add(Content("", "", DateTime.now(), [], i, i, i, [], i / 2));
    }
    var result = sGF.getContent(allContent, "oskar");
    expect(result?.length, 8);
  });
}
