import 'package:flutter/material.dart';
import 'package:todo_app/components/MyButton.dart';

class DialogBox extends StatelessWidget {
  final controller;
  VoidCallback onSave;
  VoidCallback onCancel;

  DialogBox({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.yellow[300],
      content: Container(
        height: 120,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          //get user input
          TextField(
            controller: controller,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: "Add a new task"),
          ),

          // buttons -> save + cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // save button
              MyButton(
                  text: "Save", button_color: Colors.green, onPressed: onSave),

              const SizedBox(
                width: 4,
              ),

              // cancel button
              MyButton(
                  text: "Cancel", button_color: Colors.red, onPressed: onCancel)
            ],
          )
        ]),
      ),
    );
  }
}
