/// This class represents an image of a meal.
class ImageData {
  final String _id;
  final String _url;
  final double _imageRank;
  int _positiveRating;
  int _negativeRating;

  int _individualRating;

  /// This constructor creates an image with the committed values.
  ///
  /// The required values are the [id], [url], [imageRank] and the number of positive and negative ratings of the image.
  ImageData({
    required String id,
    required String url,
    required double imageRank,
    int? individualRating,
    required int positiveRating,
    required int negativeRating,
  })  : _id = id,
        _url = url,
        _imageRank = imageRank,
        _individualRating = individualRating ?? 0,
        _positiveRating = positiveRating,
        _negativeRating = negativeRating;

  /// Returns the number of negative ratings.
  int get negativeRating => _negativeRating;

  /// Returns the number of positive ratings.
  int get positiveRating => _positiveRating;

  /// Returns the individual rating of the image.
  /// It is 0 if there is no rating, 1 for an upvote and -1 for a downvote.
  int get individualRating => _individualRating;

  /// Returns the image rank calculated by the server.
  double get imageRank => _imageRank;

  /// Returns the url to the image at the image hoster.
  String get url => _url;

  /// Returns the id of the image.
  String get id => _id;

  set individualRating(int value) {
    if(value != _individualRating) {
      if(value == 1) {
        _positiveRating++;
        if(_individualRating == -1) {
          _negativeRating--;
        }
      } else if(value == -1) {
        _negativeRating++;
        if(_individualRating == 1) {
          _positiveRating--;
        }
      } else {
        if(_individualRating == 1) {
          _positiveRating--;
        } else if(_individualRating == -1) {
          _negativeRating--;
        }
      }
    }
    _individualRating = value;
  }
}
