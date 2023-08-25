import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const int student = 200;
  const int employee = 300;
  const int pupil = 400;
  const int guest = 500;

  Price price =
      Price(student: student, employee: employee, pupil: pupil, guest: guest);

  group("constructor", () {
    test("student", () => expect(price.student, student));
    test("employee", () => expect(price.employee, employee));
    test("pupil", () => expect(price.pupil, pupil));
    test("guest", () => expect(price.guest, guest));
  });

  group("get price by category", () {
    test("student", () => expect(price.getPrice(PriceCategory.student), student));
    test("employee", () => expect(price.getPrice(PriceCategory.employee), employee));
    test("pupil", () => expect(price.getPrice(PriceCategory.pupil), pupil));
    test("guest", () => expect(price.getPrice(PriceCategory.guest), guest));
  });
}
