import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/calendar/views/calendar_screen.dart';
import 'package:mobile/features/chats/views/chat_screen.dart';
import 'package:mobile/features/chats/views/chat_list_screen.dart';
import 'package:mobile/features/chats/views/new_message_screen.dart';
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
import 'package:mobile/features/localization/language_provider.dart';
import 'package:mobile/features/login/services/login_service.dart';
import 'package:mobile/features/login/views/login_screen.dart';
import 'package:mobile/features/profile/views/user_profile_screen.dart';
import 'package:mobile/features/register/views/register_screen.dart';
import 'package:mobile/features/login/bloc/login_bloc.dart';
import 'shared/themes/styles.dart';

void main() {
  final languageProvider = LanguageProvider();
  final loginService = LoginService();
  final inventoryService = InventoryService();
  final calendarService = CalendarService();
  final homeService = HomeService();

  runApp(
    MultiBlocProvider(
      providers: [
        // LoginBloc for managing login state
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(loginService: loginService),
        ),
        // InventoryBloc for managing inventory state
        BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc(inventoryService: inventoryService),
        ),
        // CalendarBloc for calendar-related functionality
        BlocProvider<CalendarBloc>(
          create: (context) => CalendarBloc(calendarService: calendarService),
        ),
        // HomeBloc for managing the home screen's state
        BlocProvider<HomeBloc>(
          create: (context) => HomeBloc(homeService: homeService),
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
      initialRoute: '/', // Start with the Login Screen
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/chats': (context) => ChatListScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/new_message': (context) => NewMessageScreen(),
        '/construction_home': (context) => ConstructionHomeScreen(),
        '/construction_team': (context) => TeamScreen(),
        '/construction_inventory': (context) => InventoryScreen(),
        '/construction_calendar': (context) => const ConstructionCalendarScreen(),
        '/chat': (context) => ChatScreen(),
        '/register': (context) => RegisterScreen(),
      },
      theme: ThemeData(
        primaryColor: AppStyles.primaryBlue,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppStyles.primaryBlue, // Set global cursor color
          selectionHandleColor: Color.fromARGB(255, 39, 177, 241), // Handle color
        ),
      ),
    );
  }
}
