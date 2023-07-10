import 'package:mocktail/mocktail.dart';

import '../model/mocks/ApiMock.dart';
import '../model/mocks/DatabaseMock.dart';
import '../model/mocks/LocalStorageMock.dart';

void main () {
  final localStorage = LocalStorageMock();
  final api = ApiMock();
  final database = DatabaseMock();



}