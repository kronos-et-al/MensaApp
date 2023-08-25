import '../settings/PriceCategory.dart';

/// This class represents a price.
class Price {
  final int _student;
  final int _employee;
  final int _pupil;
  final int _guest;

  /// This constructor creates a new price.
  /// The required values are the prices for [student], [employee], [pupil] and [guest].
  Price({
    required int student,
    required int employee,
    required int pupil,
    required int guest,
  })  : _student = student,
        _employee = employee,
        _pupil = pupil,
        _guest = guest;

  /// Returns the price for the committed price category.
  int getPrice(PriceCategory category) {
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

  /// This method returns the price for guests.
  int get guest => _guest;

  /// Returns the price for pupils.
  int get pupil => _pupil;

  /// Returns the price for employees.
  int get employee => _employee;

  /// Returns the price for students.
  int get student => _student;
}
