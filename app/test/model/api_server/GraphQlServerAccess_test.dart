
import 'package:app/model/api_server/GraphQlServerAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:test/test.dart';

void main() async {
  final GraphQlServerAccess serverAccess = GraphQlServerAccess();

  test('graphql', () async {
    var deleted = await serverAccess.deleteDownvote(ImageData(id: "1234", url: "url", imageRank: 0, positiveRating: 0, negativeRating: 0));
    expect(deleted, true);
  });


}