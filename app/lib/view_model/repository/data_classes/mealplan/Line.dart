import 'Canteen.dart';

class Line {
  final String _id;
  final String _name;
  final Canteen _canteen;
  final int _position;

  Line({
    required String id,
    required String name,
    required Canteen canteen,
    required int position,
  })  : _id = id,
        _name = name,
        _canteen = canteen,
        _position = position;

  Map<String, dynamic> toMap() {
    return {
      'lineID': _id,
      'name': _name,
      'canteenID': _canteen.id,
      'position': _position,
    };
  }

  String get id => _id;

  String get name => _name;

  Canteen get canteen => _canteen;

  int get position => _position;
}
