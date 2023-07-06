import 'package:app/model/api_server/GraphQlServerAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() async {
  final GraphQlServerAccess serverAccess =
      GraphQlServerAccess("1f16dcca-963e-4ceb-a8ca-843a7c9277a5");

  test('environment endpoint defined', () {
    expect(const String.fromEnvironment('API_URL').isNotEmpty, true,
        reason:
            "define secret file with `--dart-define-from-file=<path to secret.json>`, see README");
  });

  test('graphql', () async {
    var deleted = await serverAccess.deleteDownvote(ImageData(
        id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
        url: "url",
        imageRank: 0,
        positiveRating: 0,
        negativeRating: 0));
    expect(deleted, true);
  });
}
