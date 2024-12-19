import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/calendar/views/calendar_screen.dart';
import 'package:mobile/features/chat/bloc/chat_bloc.dart';
import 'package:mobile/features/chat/services/chat_hub_service.dart';
import 'package:mobile/features/chat/views/chat_screen.dart';
import 'package:mobile/features/conversation_list/bloc/conversation_bloc.dart';
import 'package:mobile/features/conversation_list/services/conversation_service.dart';
import 'package:mobile/features/conversation_list/views/conversation_list_screen.dart';
import 'package:mobile/features/new_message/new_message_screen.dart';
import 'package:mobile/features/construction_calendar/bloc/calendar_bloc.dart';
import 'package:mobile/features/construction_calendar/services/calendar_service,dart';
import 'package:mobile/features/construction_calendar/views/construction_calendar_screen.dart';
import 'package:mobile/features/construction_home/views/construction_home_screen.dart';
import 'package:mobile/features/construction_inventory/blocs/inventory_bloc.dart';
import 'package:mobile/features/construction_inventory/services/inventory_service.dart';
import 'package:mobile/features/construction_inventory/views/inventory_screen.dart';
import 'package:mobile/features/construction_team/views/team_screen.dart';
import 'package:mobile/features/home/bloc/home_bloc.dart';
import 'package:mobile/features/home/services/home_service.dart';
import 'package:mobile/features/home/views/home_screen.dart';
import 'package:mobile/features/profile/bloc/profile_bloc.dart';
import 'package:mobile/features/profile/services/user_service.dart';
import 'package:mobile/shared/localization/language_provider.dart';
import 'package:mobile/features/login/services/login_service.dart';
import 'package:mobile/features/login/views/login_screen.dart';
import 'package:mobile/features/profile/views/user_profile_screen.dart';
import 'package:mobile/features/register/views/register_screen.dart';
import 'package:mobile/features/login/bloc/login_bloc.dart';
import 'shared/themes/styles.dart';

void main() {
  final languageProvider = LanguageProvider();
  // Stwórz instancje wymaganych serwisów
  final loginService = LoginService();
  final inventoryService = InventoryService();
  final calendarService = CalendarService();

  runApp(
    MultiBlocProvider(
      providers: [
        // Rejestracja LoginBloc
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(loginService: loginService),
        ),
        // Rejestracja InventoryBloc
        BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc(inventoryService: inventoryService),
        ),
        // Rejestracja CalendarBloc
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(calendarService: calendarService),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(homeService:HomeService()),
        ),
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(UserService()),
        ),
         BlocProvider<ConversationBloc>(
        create: (context) => ConversationBloc(ConversationService()),
         ),
         BlocProvider<ChatBloc>(
          create: (_) => ChatBloc(chatHubService: ChatHubService()),
        ),
      ],
      child: const BuildBuddyApp(),
    ),
  );
}

class BuildBuddyApp extends StatelessWidget {
  const BuildBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Start at the SplashScreen
      routes: {
        '/': (context) => const LoginScreen(), // Show splash screen first
        '/home': (context) => const HomeScreen(),
        '/chats': (context) => ConversationListScreen(),
        '/calendar': (context) => const CalendarScreen(), // Calendar screen
        '/profile': (context) => const UserProfileScreen(),
        '/new_message': (context) => NewMessageScreen(),
        '/construction_home': (context) => ConstructionHomeScreen(),
        '/construction_team': (context) => TeamScreen(),
        '/construction_inventory': (context) => InventoryScreen(),
        '/construction_calendar': (context) => const ConstructionCalendarScreen(),
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ChatScreen(conversationName: args['conversationName']);
        },
        '/register': (context) => RegisterScreen(),
      },
      theme: ThemeData(
        primaryColor: AppStyles.primaryBlue,
        // Set a global cursor color for all TextFields in the app
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppStyles.primaryBlue, // Set the cursor color globally
          selectionHandleColor: Color.fromARGB(255, 39, 177, 241),
        ),
      ),
    );
  }
}


// przyklad uzycia jezyka
//   import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'language_provider.dart';

// class LoginScreen extends StatelessWidget {
//   const LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final languageProvider = Provider.of<LanguageProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(languageProvider.translate('login')),
//       ),
//       body: Center(
//         child: Text(languageProvider.translate('hello')),
//       ),
//     );
//   }
// }
// przelaczanie
// IconButton(
//   icon: const Icon(Icons.language),
//   onPressed: () {
//     final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
//     final newLang = languageProvider.currentLanguage == 'en' ? 'pl' : 'en';
//     languageProvider.setLanguage(newLang);
//   },
// ),