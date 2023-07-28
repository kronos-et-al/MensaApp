import 'Canteen.dart';

/// This class represents a line.
class Line {
  final String _id;
  final String _name;
  final Canteen _canteen;
  final int _position;

  /// This constructor creates a new line.
  /// @param id The id of the line
  /// @param name The name of the line
  /// @param canteen The canteen of the line
  /// @param position The position of the line
  /// @return A new line
  Line({
    required String id,
    required String name,
    required Canteen canteen,
    required int position,
  })  : _id = id,
        _name = name,
        _canteen = canteen,
        _position = position;

  /// This method returns all attributes needed for the database.
  /// @return All attributes needed for the database
  Map<String, dynamic> toMap() {
    return {
      'lineID': _id,
      'name': _name,
      'canteenID': _canteen.id,
      'position': _position,
    };
  }

  /// This method returns the id of the line.
  /// @return The id of the line
  String get id => _id;

  /// This method returns the name of the line.
  /// @return The name of the line
  String get name => _name;

  /// This method returns the canteen of the line.
  /// @return The canteen of the line
  Canteen get canteen => _canteen;

  /// This method returns the position of the line.
  /// @return The position of the line
  int get position => _position;
}
