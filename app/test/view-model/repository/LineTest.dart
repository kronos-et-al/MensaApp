import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String id = "42";
  const String name = "vegan line";
  final Canteen canteen = Canteen(id: "1", name: "2");
  const int position = 42;

  Line line = Line(id: id, name: name, canteen: canteen, position: position);

  group("constructor", () {
    test("id", () => expect(line.id, id));
    test("name", () => expect(line.name, name));
    test("canteen", () => expect(line.canteen, canteen));
    test("position", () => expect(line.position, position));
  });
}