import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String task_name;
  final bool task_completed;
  Function(bool?)? onChanged;
  Function(BuildContext)? updateTaskFunction;
  Function(BuildContext)? deleteFunction;

  ToDoTile(
      {super.key,
      required this.task_name,
      required this.task_completed,
      required this.onChanged,
      required this.updateTaskFunction,
      this.deleteFunction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Slidable(
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: updateTaskFunction,
              icon: Icons.edit,
              backgroundColor: Colors.blue.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Colors.yellow, borderRadius: BorderRadius.circular(20)),
          child: Row(
            children: [
              // checkbox
              Checkbox(
                value: task_completed,
                onChanged: onChanged,
                activeColor: Colors.black,
              ),

              // task name
              Text(
                task_name,
                style: TextStyle(
                    decoration: task_completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
