import 'package:flutter/material.dart';

class DialogBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(String) importanceSelector;

  DialogBox({
    Key? key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    required this.importanceSelector,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String selectedImportance = ""; // Valeur par défaut

    return AlertDialog(
      backgroundColor: Colors.yellow[300],
      content: Container(
        height: 180,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Input pour la tâche
            TextField(
              cursorColor: Colors.black,
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ajouter une tâche",
              ),
            ),

            // Dropdown pour sélectionner l'importance
            DropdownButton<String>(
              value: selectedImportance.isNotEmpty ? selectedImportance : null,
              hint: Text("Sélectionner l'importance"),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  importanceSelector(newValue);
                }
              },
              items: ["Très important", "Important", "Pas très important", ""]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.isEmpty ? "Aucun" : value),
                );
              }).toList(),
            ),

            // Boutons "Enregistrer" et "Annuler"
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onSave,
                  child: Text("Enregistrer"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text("Annuler"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
