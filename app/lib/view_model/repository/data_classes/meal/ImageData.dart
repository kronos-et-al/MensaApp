class ImageData {

  final String _id;
  final String _url;
  final double _imageRank;
  final int? _individualRating;
  final int _positiveRating;
  final int _negativeRating;



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

  /// This method returns the id of the image.
  /// @return The id of the image
  String get id => _id;

  /// This method returns the url of the image.
  /// @return The url of the image
  String get url => _url;

  /// This method returns the rank of the image calculated by the server.
  /// @return The rank of the image calculated by the server
  double get imageRank => _imageRank;

  /// This method returns the individual rating of the image.
  /// @return The individual rating of the image if it exists, otherwise null
  int? get individualRating => _individualRating;

  /// This method returns the number of positive ratings of the image.
  /// @return The number of positive ratings of the image
  int get positiveRating => _positiveRating;

  /// This method returns the number of negative ratings of the image.
  /// @return The number of negative ratings of the image
  int get negativeRating => _negativeRating;

  /// This method creates an image from a map.
  /// @return a map with the id and the url of the image
  Map<String, dynamic> toMap() {
    return {
      'imageID': _id,
      'url': _url,
    };
  }
}