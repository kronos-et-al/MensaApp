/// This class represents a canteen.
class Canteen {
  final String _id;
  final String _name;

  /// constructor that creates a new canteen.
  ///
  /// The required values are the [id] and the [name] of the canteen.
  Canteen({
    required String id,
    required String name,
  })  : _id = id,
        _name = name;

  /// Returns the id of the canteen.
  String get id => _id;

  /// Returns the name of the canteen.
  String get name => _name;

  /// Returns all attributes as a map.
  Map<String, dynamic> toMap() {
    return {
      'canteenID': _id,
      'name': _name,
    };
  }
}
