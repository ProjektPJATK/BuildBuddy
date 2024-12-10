import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../services/register_service.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
      RegisterSubmitted event, Emitter<RegisterState> emit) async {
    emit(RegisterLoading());

    try {
      final isSuccess = await RegisterService.registerUser(
        name: event.name,
        surname: event.surname,
        email: event.email,
        telephoneNr: event.telephoneNr,
        password: event.password,
      );

      if (isSuccess) {
        emit(RegisterSuccess());
      } else {
        emit(RegisterFailure(error: 'Rejestracja nie powiodła się'));
      }
    } catch (e) {
      emit(RegisterFailure(error: 'Błąd: $e'));
    }
  }
}
