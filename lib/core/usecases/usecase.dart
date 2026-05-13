import 'package:equatable/equatable.dart';

/// Base class for all domain layer use cases.
/// [T] is the return type, [Params] are the input parameters.
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Placeholder class for use cases that do not require any input parameters.
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
