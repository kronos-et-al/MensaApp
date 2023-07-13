class Image {

  final String _id;
  final String _url;
  final double _imageRank;
  final int? _individualRating;
  final int _positiveRating;
  final int _negativeRating;

  Image({
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

  int? get individualRating => _individualRating;

  double get imageRank => _imageRank;

  String get url => _url;

  String get id => _id;

  Map<String, dynamic> toMap() {
    return {
      'imageID': _id,
      'url': _url,
    };
  }
}