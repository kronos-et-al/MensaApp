import 'package:objectbox/objectbox.dart';

@Entity()
class BoxPrice {
  int id = 0;
  
  int student;
  int employee;
  int pupil;
  int guest;

  BoxPrice({
    this.student = 0,
    this.employee = 0,
    this.pupil = 0,
    this.guest = 0,
  });
}
