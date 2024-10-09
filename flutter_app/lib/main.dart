import 'package:flutter/material.dart';
import 'package:flutter_app/screen/chat/chat_screen.dart';
import 'package:flutter_app/screen/enfant_screen.dart';
import 'package:flutter_app/screen/home_screen.dart';
import 'package:flutter_app/screen/kermesses/kermesse_details.dart';
import 'package:flutter_app/screen/kermesses/kermesse_list.dart';
import 'package:flutter_app/screen/auth/login_screen.dart';
import 'package:flutter_app/screen/organisateur/organisateur_screen.dart';
import 'package:flutter_app/screen/parent/parent_screen.dart';
import 'package:flutter_app/screen/parent/register_child.dart';
import 'package:flutter_app/screen/auth/profile_screen.dart';
import 'package:flutter_app/screen/auth/register_screen.dart';
import 'package:flutter_app/screen/stocks/gestion_stock.dart';
import 'package:flutter_app/screen/tickets_screen.dart';
import 'package:flutter_app/screen/tombolas/tombola_details.dart';
import 'package:flutter_app/screen/users/users_tickets_list.dart';
import 'package:flutter_app/services/auth_service.dart';
import 'package:flutter_app/services/chat_service.dart';
import 'package:flutter_app/services/users_points_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'config/config.dart';
import 'models/kermesse_model.dart';
import 'models/tombola_model.dart';
import 'screen/splash_screen.dart';


Future<void> main() async {

  try {
    await dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();
    Stripe.publishableKey = dotenv.env['STRIPE_KEY_PUBLIC']!;
    await Stripe.instance.applySettings();
     print('API URL: ${AppConfig.getApiAuthority()}');
  } catch (e) {
    print("Erreur lors du chargement du fichier .env: $e");

  }
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthService>(
            create: (_) => AuthService(),
          ),
          ProxyProvider<AuthService, UserPointsService>(
            update: (_, authService, __) => UserPointsService(
            ),
          ),
          ChangeNotifierProxyProvider2<AuthService, UserPointsService, ChatService>(
            create: (context) => ChatService(
              baseUrl: AppConfig.webSocketUrl,
              userId: Provider.of<AuthService>(context, listen: false).userId ?? 0,
            ),
            update: (_, authService, userPointsService, previousChatService) {
              if (previousChatService == null) {
                return ChatService(
                  baseUrl: AppConfig.webSocketUrl,
                  userId: authService.userId ?? 0,
                );
              }
              previousChatService.updateUserId(authService.userId ?? 0);
              return previousChatService;
            },
          ),
        ],

      child: MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (ctx, auth, _) => MaterialApp(
        title: 'Kemermess App',
        theme: ThemeData(
          primarySwatch: Colors.orange,
          hintColor: Colors.orangeAccent,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      home: auth.isAuth
          ?  RoleBasedHomeScreen()
          : FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, authResultSnapshot) {
          if (authResultSnapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }
          return authResultSnapshot.data == true ? RoleBasedHomeScreen() : LoginScreen();
        },
      ),
        initialRoute: '/kermesses',
          routes: {
            '/login': (ctx) => LoginScreen(),
            '/register': (ctx) => RegisterScreen(),
            '/register-child': (ctx) => RegisterChildScreen(),
            '/home': (ctx) => HomeScreen(),
            '/profile': (ctx) => ProfileScreen(),
            '/tickets': (ctx) => TicketsScreen(),
            '/organisateur': (ctx) => OrganisateurScreen(),
            '/parent': (ctx) => ParentHomeScreen(),
            '/eleve': (ctx) => EnfantScreen(),
            '/kermesses': (ctx) => KermesseListScreen(),
            '/stocks': (ctx) => GestionStocksAccueil(),



          },
    onGenerateRoute: (settings) {
    switch (settings.name) {
    case '/kermesse_detail':
    final kermesse = settings.arguments as Kermesse;
    return MaterialPageRoute(
    builder: (context) => KermesseDetailScreen(kermesse: kermesse),
    );
    case '/tombola_detail':
    final tombola = settings.arguments as Tombola;
    return MaterialPageRoute(
    builder: (context) => TombolaDetailScreen(tombolaId: tombola!.id, tombola: tombola),
    );
    case '/chat':
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
    builder: (context) {
    final chatService = Provider.of<ChatService>(context, listen: false);
    return ChatScreen(
    currentUserId: chatService.userId,
    otherUserId: args['otherUserId'] as int,
    baseUrl: AppConfig.webSocketUrl,
    );
    },
    );

      default:
        return null;
    }
    },
    ),
    );
  }
}

class RoleBasedHomeScreen extends StatelessWidget {
  const RoleBasedHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userRole = authService.user?.role;

    switch (userRole) {
      case 'PARENT':
        return ParentHomeScreen();
      case 'ELEVE':
        return EnfantScreen();
      case 'TENEUR_STAND':
        return EnfantScreen();
      case 'ADMIN':
        return EnfantScreen();
      case 'ORGANISATEUR':
        return OrganisateurScreen();
      default:
      // Gérer le cas où le rôle n'est pas reconnu
        return const Scaffold(
          body: Center(child: Text('Rôle non reconnu')),
        );
    }
  }
}