abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<dynamic> teams;
  HomeLoaded(this.teams);
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
