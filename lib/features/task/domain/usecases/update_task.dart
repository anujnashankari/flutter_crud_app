import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/task.dart';
import '../repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;
  
  UpdateTask(this.repository);
  
  Future<Either<Failure, Task>> call(Task task) async {
    return await repository.updateTask(task);
  }
}
