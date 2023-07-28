import '../settings/PriceCategory.dart';

/// This class represents a price.
class Price {
  final int _student;
  final int _employee;
  final int _pupil;
  final int _guest;

  /// This constructor creates a new price.
  /// @param student The price for students
  /// @param employee The price for employees
  /// @param pupil The price for pupils
  /// @param guest The price for guests
  /// @return A new price
  Price({
    required int student,
    required int employee,
    required int pupil,
    required int guest,
  })  : _student = student,
        _employee = employee,
        _pupil = pupil,
        _guest = guest;

  /// This method returns the price for the committed price category.
  /// @param category The price category
  /// @return The price for the committed price category
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

  /// This method returns all attributes needed for the database.
  /// @return All attributes needed for the database
  Map<String, dynamic> toMap() {
    return {
      'priceStudent': _student,
      'priceEmployee': _employee,
      'pricePupil': _pupil,
      'priceGuest': _guest,
    };
  }

  /// This method returns the price for guests.
  /// @return The price for guests
  int get guest => _guest;

  /// This method returns the price for pupils.
  /// @return The price for pupils
  int get pupil => _pupil;

  /// This method returns the price for employees.
  /// @return The price for employees
  int get employee => _employee;

  /// This method returns the price for students.
  /// @return The price for students
  int get student => _student;
}
