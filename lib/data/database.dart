import 'package:hive_flutter/hive_flutter.dart';

class Database {
  // reference our box
  final _myhivebox = Hive.box('myhivebox');

  // list of todo tasks
  List toDoList = [];

  // if its first time ever opening the app
  void createInitialData() {
    toDoList = [
      ["Start adding tasks", false, [DateTime.now()], "Important"]
    ];
  }

  // load data from the database
  void loadData() {
    toDoList = (_myhivebox.get("TODOLIST"));
    print("toDoList " + toDoList.toString());
  }

  // update the database
  void updateDatabase() {
    _myhivebox.put("TODOLIST", toDoList);
  }

  // update a task the database
  void updateTask() {
    _myhivebox.put("TODOLIST", toDoList);
  }
}
