import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';
import 'package:todo_app/data/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controller
  final _controller = TextEditingController();

  // reference the hive box
  final _myhivebox = Hive.box('myhivebox');
  Database db = Database();

  @override
  void initState() {
    // if its 1st time ever opening the app then create default data
    if (_myhivebox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      // there already exists data
      db.loadData();
    }

    super.initState();
  }

  // checkbox was tapped
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
    });
    db.updateDatabase();
  }

  // to save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // to create a new task
  void createNewTask() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: saveNewTask,
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  // if its saving action = 0 and if its updating action = 1
  void showDialogBox(int action, var index) {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBox(
            controller: _controller,
            onSave: action == 0 ? saveNewTask : () => updateTask(index),
            onCancel: () => Navigator.of(context).pop(),
          );
        });
  }

  // to delete a task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  // to update a task
  void updateTask(var index) {
    setState(() {
      db.toDoList[index][0] = _controller.text;
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        centerTitle: true,
        title: Text('TO DO'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialogBox(0, 0),
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            task_name: db.toDoList[index][0],
            task_completed: db.toDoList[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            updateTaskFunction: (context) {
              _controller.text = db.toDoList[index][0];
              showDialogBox(1, index);
            },
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
