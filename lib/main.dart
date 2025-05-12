import 'package:currency_converter/services/api_service.dart';
import 'package:currency_converter/services/conta_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';
import 'pages/cadastro_page.dart';
import 'pages/lista_contas_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<ContaService>(
          create: (context) => ContaService(
            apiService: context.read<ApiService>(),
          ),
        ),
        // ... outros providers
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ContaService>(create: (_) => ContaService()),
      ],
      child: MaterialApp(
        title: 'Gerenciador de Contas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginPage(
            onRegisterClicked: () {
              Navigator.pushNamed(context, '/cadastro');
            },
          ),
          '/cadastro': (context) => CadastroPage(
            onLoginClicked: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
          '/contas': (context) => const ListaContasPage(),
        },
      ),
    );
  }
}