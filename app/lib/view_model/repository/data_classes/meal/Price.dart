import '../settings/PriceCategory.dart';

class Price {

  final int _student;
  final int _employee;
  final int _pupil;
  final int _guest;

  Price({
    required int student,
    required int employee,
    required int pupil,
    required int guest,
  })  : _student = student,
        _employee = employee,
        _pupil = pupil,
        _guest = guest;

  getPrice(PriceCategory category) {
    switch (category) {
      case PriceCategory.student:
        return _student;
      case PriceCategory.employee:
        return _employee;
      case PriceCategory.pupil:
        return _pupil;
      case PriceCategory.guest:
        return _guest;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'priceStudent': _student,
      'priceEmployee': _employee,
      'pricePupil': _pupil,
      'priceGuest': _guest,
    };
  }

  int get guest => _guest;

  int get pupil => _pupil;

  int get employee => _employee;

  int get student => _student;
}