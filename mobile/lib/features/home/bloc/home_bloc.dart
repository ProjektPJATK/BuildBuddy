import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'home_event.dart';
import 'home_state.dart';
import '../services/home_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService homeService;

  HomeBloc({required this.homeService}) : super(HomeInitial()) {
    on<FetchTeamsEvent>(_onFetchTeams);
    on<FetchTeamsFromCacheEvent>(_onFetchTeamsFromCache);
  }

  /// Obsługa eventu do pobierania zespołów z backendu


Future<void> _onFetchTeams(FetchTeamsEvent event, Emitter<HomeState> emit) async {
  try {
    await Future.delayed(const Duration(milliseconds: 500));
    final teams = await homeService.fetchTeams(event.userId);

    // Cache the fetched teams
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cachedTeams', jsonEncode(teams));

    emit(HomeLoaded(teams)); // Aktualizacja danych
    print("Emit HomeLoaded from FetchTeamsEvent");
  } catch (e) {
    emit(HomeError('Błąd pobierania danych: ${e.toString()}'));
    print("Emit HomeError from FetchTeamsEvent: $e");
  }
}

Future<void> _onFetchTeamsFromCache(FetchTeamsFromCacheEvent event, Emitter<HomeState> emit) async {
  print("Handling FetchTeamsFromCacheEvent");
  final cachedTeams = await _loadCachedTeams();
  if (cachedTeams.isNotEmpty) {
    emit(HomeLoaded(cachedTeams)); // Emituj dane z cache
    print("Emit HomeLoaded from FetchTeamsFromCacheEvent");
  } else {
    print("No cached data available");
  }
}

  /// Pobieranie zespołów z pamięci cache
  Future<List<dynamic>> _loadCachedTeams() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cachedTeams');
    if (cachedData != null) {
      return jsonDecode(cachedData) as List<dynamic>;
    }
    return [];
  }
}
