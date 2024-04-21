import 'package:app/model/database/model/db_meal_environment_info.dart';
import 'package:app/model/database/model/db_side_environment_info.dart';

final List<String> migrationV3_V4 = [
  '''
  ${DBMealEnvironmentInfo.initTable()};
  ''',
  '''
  ${DBSideEnvironmentInfo.initTable()};
'''
];
