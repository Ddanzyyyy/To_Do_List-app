  import 'package:flutter/foundation.dart';
  import 'package:to_do_list_app/database_helper.dart';
  import '../models/task.dart';

  // providers/task_provider.dart
  class TaskProvider extends ChangeNotifier {
    List<Task> _tasks = [];
    List<Task> get tasks => _tasks;

    TaskProvider() {
      loadTasks();
    }

    get isDarkMode => null;

    Future<void> loadTasks() async {
      _tasks = await DatabaseHelper().getTasks();
      notifyListeners();
    }

    Future<void> addTask(Task task) async {
      // Simpan task ke database dan dapatkan ID baru
      int newId = await DatabaseHelper().insertTask(task);
      task.id = newId; // Set ID baru ke objek Task
      _tasks.add(task);
      notifyListeners();
    }

    Future<void> updateTask(int index, Task newTask) async {
      if (index >= 0 && index < _tasks.length) {
        // Pastikan ID dari task yang lama tetap dipertahankan
        final oldTask = _tasks[index];
        final updatedTask = newTask.copyWith(id: oldTask.id);
        
        await DatabaseHelper().updateTask(updatedTask);
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    }

    Future<void> removeTask(Task task) async {
      if (task.id != null) {
        await DatabaseHelper().deleteTask(task.id!);
        _tasks.removeWhere((t) => t.id == task.id);
        notifyListeners();
      } else {
        print("Error: task.id is null");
      }
    }

    Future<void> toggleTaskCompletion(Task task) async {
      if (task.id != null) {
        task.isCompleted = !task.isCompleted;
        await DatabaseHelper().updateTask(task);
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = task;
        }
        notifyListeners();
      }
    }

    void toggleDarkMode() {}
  }