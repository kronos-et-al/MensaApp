import '../data_classes/mealplan/Mealplan.dart';

abstract class IServerAccess {
  Future<Result<List<Mealplan>>> updateAll();

}