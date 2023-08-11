/// This class represents a canteen.
class Canteen {
  final String _id;
  final String _name;

  /// This constructor creates a new canteen.
  /// @param id The id of the canteen
  /// @param name The name of the canteen
  /// @return A new canteen
  Canteen({
    required String id,
    required String name,
  })  : _id = id,
        _name = name;

  /// This method returns the id of the canteen.
  /// @return The id of the canteen
  String get id => _id;

  /// This method returns the name of the canteen.
  /// @return The name of the canteen
  String get name => _name;
}
