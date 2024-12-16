import 'package:flutter_bloc/flutter_bloc.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import '../services/conversation_service.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationService conversationService;

  ConversationBloc({required this.conversationService}) : super(ConversationLoading()) {
    on<LoadConversationsEvent>(_onLoadConversations);
  }

  Future<void> _onLoadConversations(LoadConversationsEvent event, Emitter<ConversationState> emit) async {
    emit(ConversationLoading());

    // 1. Wczytujemy z cache
    final cachedConversations = await conversationService.loadConversationsFromCache();
    if (cachedConversations.isNotEmpty) {
      // Wyświetlamy dane z cache natychmiast
      final processedCache = await conversationService.processConversations(cachedConversations);
      emit(ConversationLoaded(conversations: processedCache));
    }

    try {
      // 2. W tle pobieramy z backendu
      final rawConversations = await conversationService.fetchConversations();
      // Zapisujemy do cache
      await conversationService.saveConversationsToCache(rawConversations);
      // Przetwarzamy na List<String>
      final processed = await conversationService.processConversations(rawConversations);
      emit(ConversationLoaded(conversations: processed));
    } catch (e) {
      // Jeśli w cache nic nie było, a serwer się wywalił, emituj błąd
      if (cachedConversations.isEmpty) {
        emit(ConversationError('Failed to load conversations: $e'));
      }
      // W przeciwnym razie zostaw dane z cache
    }
  }
}
