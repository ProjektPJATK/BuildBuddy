import 'package:equatable/equatable.dart';
import 'package:mobile/features/profile/models/user_model.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Pobieranie profilu
class FetchProfileEvent extends ProfileEvent {}

// Pobieranie profilu z cache
class FetchProfileFromCacheEvent extends ProfileEvent {}

// Wylogowanie użytkownika
class LogoutEvent extends ProfileEvent {}

// Edycja profilu użytkownika
class EditProfileEvent extends ProfileEvent {
  final User updatedProfile;

  EditProfileEvent(this.updatedProfile);

  @override
  List<Object?> get props => [updatedProfile];
}
