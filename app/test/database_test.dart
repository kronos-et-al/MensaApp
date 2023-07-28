import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';


Meal getMeal() {
  return Meal(id: "18fb9f41-b4e8-4c6c-8b62-49ba63665516", name: "DummyMeal", foodType: FoodType.beef, price: Price(student: 200, employee: 200, pupil: 200, guest: 200));
}




void main() {
  var database = SQLiteDatabaseAccess();
  database.addFavorite(getMeal());
}