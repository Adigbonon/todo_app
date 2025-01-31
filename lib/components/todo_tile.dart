import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ToDoTile extends StatelessWidget {
  final String task_name;
  final bool task_completed;
  final List<DateTime> task_dates; // Liste de dates
  final String importance; // Degré d'importance
  final Function(bool?) onChanged;
  final Function(BuildContext) updateTaskFunction;
  final Function(BuildContext) deleteFunction;

  const ToDoTile({
    Key? key,
    required this.task_name,
    required this.task_completed,
    required this.task_dates,
    required this.importance,
    required this.onChanged,
    required this.updateTaskFunction,
    required this.deleteFunction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDates = task_dates
        .map((date) => "📅 ${date.day}/${date.month}/${date.year} - 🕒 ${date.hour}:${date.minute}")
        .join("\n"); // Affiche chaque date sur une nouvelle ligne

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: updateTaskFunction,
              backgroundColor: Colors.blue,
              icon: Icons.edit,
              label: 'Modifier',
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              backgroundColor: Colors.red,
              icon: Icons.delete,
              label: 'Supprimer',
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              task_name,
              style: TextStyle(
                decoration: task_completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formattedDates, style: TextStyle(color: Colors.grey[700])),
                if (importance.isNotEmpty)
                  Text("⭐ Importance : $importance",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            leading: Checkbox(value: task_completed, onChanged: onChanged),
          ),
        ),
      ),
    );
  }
}
