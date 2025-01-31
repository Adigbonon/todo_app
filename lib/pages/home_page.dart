import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/components/dialog_box.dart';
import 'package:todo_app/components/todo_tile.dart';
import 'package:todo_app/data/database.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text controller
  final _controller = TextEditingController();

  List<DateTime> _selectedDates = [];
  String _selectedImportance = "";

  // reference the hive box
  final _myhivebox = Hive.box('myhivebox');
  Database db = Database();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  int getImportanceValue(String importance) {
    switch (importance.toLowerCase()) {
      case "Très important":
        return 1;
      case "Important":
        return 2;
      case "Pas très important":
        return 3;
      default:
        return 4; // Pas d'importance définie = priorité la plus basse
    }
  }

  Map<String, Map<String, dynamic>> groupTasksByDate() {
    Map<String, Map<String, dynamic>> groupedTasks = {};

    for (var task in db.toDoList) {
      if (task[2].isNotEmpty) {
        DateTime firstDate = task[2][0]; // Prend la première date pour le tri
        String formattedDate = "${firstDate.day}/${firstDate.month}/${firstDate.year}";

        if (!groupedTasks.containsKey(formattedDate)) {
          groupedTasks[formattedDate] = {
            "tasks": [],
            "completed": 0,
          };
        }

        // Ajouter la tâche à la liste
        groupedTasks[formattedDate]!["tasks"].add(task);

        // Vérifier si la tâche est complétée
        if (task[1] == true) {
          groupedTasks[formattedDate]!["completed"] += 1;
        }
      }
    }

    // 🔹 Trier chaque groupe de tâches par importance
    groupedTasks.forEach((date, data) {
      data["tasks"].sort((a, b) => getImportanceValue(a[3].toString().toLowerCase()).compareTo(getImportanceValue(b[3].toString().toLowerCase())));
    });

    return groupedTasks;
  }

  @override
  void initState() {
    tz.initializeTimeZones();
    initializeNotifications();
    requestIOSPermissions(); // Demande l'autorisation sur iOS

    if (_myhivebox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }

    checkPendingTasksBeforeMidnight();
    super.initState();
  }

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
        alert: true, badge: true, sound: true);
  }

  void checkPendingTasksBeforeMidnight() {
    Timer.periodic(Duration(minutes: 1), (Timer timer) {
      DateTime now = DateTime.now();
      if (now.hour == 23 && now.minute == 55) {
        notifyIfTasksPending();
      }
    });
  }

  Future<void> notifyIfTasksPending() async {
    DateTime today = DateTime.now();
    String formattedDate = "${today.day}/${today.month}/${today.year}";

    List tasksForToday = db.toDoList.where((task) {
      List<DateTime> taskDates = List<DateTime>.from(task[2]);
      return taskDates.any((date) =>
      date.day == today.day &&
          date.month == today.month &&
          date.year == today.year);
    }).toList();

    int totalTasks = tasksForToday.length;
    int completedTasks = tasksForToday.where((task) => task[1] == true).length;

    if (totalTasks > 0 && completedTasks < totalTasks) {
      await sendNotification(totalTasks - completedTasks);
    }
  }

  Future<void> sendNotification(int pendingTasks) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'todo_channel',
      'Tâches non complétées',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      "Tâches incomplètes 📅",
      "⏳ Il vous reste $pendingTasks tâche(s) à terminer avant minuit !",
      platformChannelSpecifics,
    );
  }

  // checkbox was tapped
  void updateTask(int index, List<DateTime> selectedDates, String importance) {
    setState(() {
      db.toDoList[index] = [_controller.text, db.toDoList[index][1], selectedDates, importance];
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  // Fonction qui met à jour l'état de la tâche (complétée ou non)
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1]; // Inversion de l'état
    });
    db.updateDatabase();
  }

  // to save new task
  void saveNewTask(List<DateTime> selectedDates, String importance) {
    String taskName = _controller.text; // ✅ Sauvegarde le texte AVANT de vider le champ

    setState(() {
      db.toDoList.add([taskName, false, selectedDates, importance]);
      _controller.clear();  // ✅ On efface après avoir enregistré le nom de la tâche
    });

    scheduleTaskNotifications(selectedDates, taskName); // ✅ Envoie le bon nom de tâche

    Navigator.of(context).pop();
    db.updateDatabase();
  }

  void scheduleTaskNotifications(List<DateTime> taskDates, String taskName) {
    print("🔔 Planification de la notification pour : $taskName");

    for (var date in taskDates) {
      if (date.isAfter(DateTime.now())) {
        print("📅 Notification prévue pour : $date");
        scheduleNotification(date, taskName);
      }
    }
  }

  Future<void> scheduleNotification(DateTime dateTime, String taskName) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_channel',
      'Tâches programmées',
      importance: Importance.high,
      priority: Priority.high,
    );

    final platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // Convertir DateTime en TZDateTime pour la programmation de notification
    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      dateTime.millisecondsSinceEpoch ~/ 1000, // ID unique basé sur le timestamp
      "📌 Rappel de tâche",
      "C'est l'heure d'effectuer : $taskName ⏰",
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // to create a new task
  void createNewTask() async {
    _selectedDates = [];

    while (true) {
      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );

      if (selectedDate == null) break; // Arrête si l'utilisateur annule

      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        selectedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        _selectedDates.add(selectedDate);
      }
    }

    // Sélection de l'importance
    _selectedImportance = ""; // Importance par défaut

    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSave: () => saveNewTask(_selectedDates, _selectedImportance),
          onCancel: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          importanceSelector: (value) {
            setState(() {
              _selectedImportance = value;
            });
          },
        );
      },
    );

  }

  // to delete a task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, dynamic>> groupedTasks = groupTasksByDate(); // Regrouper les tâches par date

    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(
        centerTitle: true,
        title: Text('TO DO'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.clear();
          createNewTask();
        },
        child: Icon(Icons.add),
      ),
      body: ListView(
        children: groupedTasks.keys.map((date) {
          int totalTasks = groupedTasks[date]!["tasks"].length;
          int completedTasks = groupedTasks[date]!["completed"];
          int percentage = totalTasks > 0 ? ((completedTasks / totalTasks) * 100).round() : 0; // Calcul du pourcentage

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "$date - ✅ $percentage% de tâches effectuées", // Ajout du pourcentage
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              ...groupedTasks[date]!["tasks"].map((task) {
                int index = db.toDoList.indexOf(task);
                return ToDoTile(
                  task_name: task[0],
                  task_completed: task[1],
                  task_dates: List<DateTime>.from(task[2]), // Liste de dates
                  importance: task[3],
                  onChanged: (value) => checkBoxChanged(value, index),
                  updateTaskFunction: (context) async {
                    _controller.text = db.toDoList[index][0];

                    List<DateTime> newSelectedDates = List.from(task[2]); // Copie des dates existantes
                    String newImportance = task[3];

                    while (true) {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (selectedDate == null) break;

                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (selectedTime != null) {
                        selectedDate = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        newSelectedDates.add(selectedDate);
                      }
                    }

                    updateTask(index, newSelectedDates, newImportance);
                  },
                  deleteFunction: (context) => deleteTask(index),
                );
              }).toList(),
            ],
          );
        }).toList(),
      ),
    );
  }
}
