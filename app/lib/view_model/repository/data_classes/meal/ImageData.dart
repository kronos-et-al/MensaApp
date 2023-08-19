/// This class represents an image of a meal.
class ImageData {
  final String _id;
  final String _url;
  final double _imageRank;
  int _positiveRating;
  int _negativeRating;

  int _individualRating;

  /// This constructor creates an image with the committed values.
  /// @param id The id of the image
  /// @param url The url of the image
  /// @param imageRank The rank of the image calculated by the server
  /// @param individualRating The individual rating of the image
  /// @param positiveRating The number of positive ratings of the image
  /// @param negativeRating The number of negative ratings of the image
  /// @return An image with the committed values
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

  /// The method returns the number of negative ratings.
  int get negativeRating => _negativeRating;

  /// The method returns the number of positive ratings.
  int get positiveRating => _positiveRating;

  /// The method returns the individual rating of the image.
  /// It is 0 if there is no rating, 1 for an upvote and -1 for a downvote.
  int get individualRating => _individualRating;

  /// The method returns the image rank calculated by the server.
  double get imageRank => _imageRank;

  /// The method returns the url to the image at the image hoster.
  String get url => _url;

  /// The method returns the id of the image.
  String get id => _id;

  /// The method changes the value of [_individualRating] to the value of an upvote.
  void upvote() {
    _positiveRating += _individualRating == 1 ? 0 : 1;
    _negativeRating += _individualRating == -1 ? -1 : 0;
    _individualRating = 1;
  }

  /// The method changes the value of [_individualRating] to the value of a downvote.
  void downvote() {
    _positiveRating += _individualRating == 1 ? -1 : 0;
    _negativeRating += _individualRating == -1 ? 0 : 1;
    _individualRating = -1;
  }

  /// The method changes the value of [_individualRating] to the value of no vote.
  void deleteRating() {
    _individualRating = 0;
  }

  /// The method returns the information that are stored in a map.
  Map<String, dynamic> toMap() {
    return {
      'imageID': _id,
      'url': _url,
    };
  }
}
