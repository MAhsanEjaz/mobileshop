class TaskModel {
  int? id;
  String? name;

  List<MySubTasks>? subTask;

  TaskModel({this.id, this.name, this.subTask});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subTask': subTask?.map((e) => e.toJson()).toList() ?? [],
    };
  }
}

class MySubTasks {
  int? id;
  int? taskId;
  bool? isCompleted;
  String? subTask;

  MySubTasks({this.subTask, this.id, this.taskId, this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subTask': subTask,
      'taskId': taskId,
      'isCompleted': isCompleted,
    };
  }
}
