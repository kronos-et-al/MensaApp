class Canteen {

  final String _id;
  final String _name;

  Canteen({
    required String id,
    required String name,
  })  : _id = id,
        _name = name;

  String get id => _id;

  String get name => _name;

  Map<String, dynamic> toMap() {
    return {
      'canteenID': _id,
      'name': _name,
    };
  }

}