/// This class represents an image of a meal.
class ImageData {
  final String _id;
  final String _url;
  final double _imageRank;
  final int _positiveRating;
  final int _negativeRating;

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

  /// Sets the value of [_individualRating] to the value of an upvote.
  void upvote() {
    _individualRating = 1;
  }

  /// Sets the value of [_individualRating] to the value of a downvote.
  void downvote() {
    _individualRating = -1;
  }

  /// Sets the value of [_individualRating] to the value of no vote.
  void deleteRating() {
    _individualRating = 0;
  }

  /// Returns the information that are stored in a map.
  Map<String, dynamic> toMap() {
    return {
      'imageID': _id,
      'url': _url,
    };
  }
}
