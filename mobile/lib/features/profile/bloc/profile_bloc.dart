import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/user_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserService userService;

  ProfileBloc(this.userService) : super(ProfileInitial()) {
    on<FetchProfileFromCacheEvent>(_onFetchProfileFromCache);
    on<FetchProfileEvent>(_onFetchProfile);
    on<LogoutEvent>(_onLogout);
    on<EditProfileEvent>(_onEditProfile);
  }

  Future<void> _onFetchProfileFromCache(
      FetchProfileFromCacheEvent event, Emitter<ProfileState> emit) async {
    try {
      final user = await userService.getCachedUserProfile();
      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('No cached profile found'));
      }
    } catch (e) {
      emit(ProfileError('Error loading cached profile'));
    }
  }

  Future<void> _onFetchProfile(
      FetchProfileEvent event, Emitter<ProfileState> emit) async {
    try {
      final user = await userService.getUserProfile();
      await userService.cacheUserProfile(user);
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileError('Failed to fetch profile'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await userService.logout();
      emit(LogoutSuccess());
    } catch (e) {
      emit(ProfileError('Logout failed'));
    }
  }

  Future<void> _onEditProfile(
      EditProfileEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      await userService.editUserProfile(event.updatedProfile);
      await userService.cacheUserProfile(event.updatedProfile);
      emit(ProfileLoaded(event.updatedProfile));
    } catch (e) {
      emit(ProfileError('Failed to edit profile'));
    }
  }
}
