import 'package:objectbox/objectbox.dart';

@Entity()
class Todo {
  @Id()
  int id;
  String title;
  String description;
  bool isCompleted;

  Todo({
    this.id = 0,
    required this.title,
    this.description = '',
    this.isCompleted = false,
  });
}