class ImageData {

  final String _id;
  final String _url;
  final double _imageRank;
  final int _positiveRating;
  final int _negativeRating;

  int? _individualRating;

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
        _individualRating = individualRating,
        _positiveRating = positiveRating,
        _negativeRating = negativeRating;

  int get negativeRating => _negativeRating;

  int get positiveRating => _positiveRating;

  int get individualRating => _individualRating ?? 0;

  double get imageRank => _imageRank;

  String get url => _url;

  String get id => _id;


  set individualRating(int value) {
    _individualRating = value;
  }

  Map<String, dynamic> toMap() {
    return {
      'imageID': _id,
      'url': _url,
    };
  }
}