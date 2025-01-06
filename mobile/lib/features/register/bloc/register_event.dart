import 'package:equatable/equatable.dart';
import 'package:mobile/features/profile/models/user_model.dart';


abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final User user;

  const RegisterSubmitted(this.user);

  @override
  List<Object> get props => [user];
}
