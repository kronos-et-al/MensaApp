import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String id = "42";
  const String name = "vegan canteen";

  Canteen canteen = Canteen(id: id, name: name);

  group("constructor", () {
    test("id", () => expect(canteen.id, id));
    test("name", () => expect(canteen.name, name));
  });
}