import 'Canteen.dart';

/// This class represents a line.
class Line {
  final String _id;
  final String _name;
  final Canteen _canteen;
  final int _position;

  /// This constructor creates a new line.
  ///
  /// The required values are the [id], [name], [canteen] and the original [position] of the line.
  Line({
    required String id,
    required String name,
    required Canteen canteen,
    required int position,
  })  : _id = id,
        _name = name,
        _canteen = canteen,
        _position = position;

  /// This method returns the id of the line.
  String get id => _id;

  /// Returns the name of the line.
  String get name => _name;

  /// Returns the canteen of the line.
  Canteen get canteen => _canteen;

  /// Returns the position of the line.
  int get position => _position;
}
