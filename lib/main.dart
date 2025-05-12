import 'package:currency_converter/pages/cotacoes_page.dart';
import 'package:currency_converter/pages/menu_page.dart';
import 'package:currency_converter/services/api_service.dart';
import 'package:currency_converter/services/conta_service.dart';
import 'package:currency_converter/services/cotacao_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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

  // Cria API e serviços antes de iniciar o app
  final apiService = ApiService();
  final contaService = ContaService(apiService: apiService);
  final cotacaoService = CotacaoService(
    apiService: apiService,
    contaService: contaService,
  );

  runApp(MyApp(
    apiService: apiService,
    contaService: contaService,
    cotacaoService: cotacaoService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final ContaService contaService;
  final CotacaoService cotacaoService;

  const MyApp({
    Key? key,
    required this.apiService,
    required this.contaService,
    required this.cotacaoService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ApiService>.value(value: apiService),
        Provider<ContaService>.value(value: contaService),
        Provider<CotacaoService>.value(value: cotacaoService),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Gerenciador de Contas',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
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
          '/menu': (context) => const MenuPage(),
          '/contas': (context) => const ListaContasPage(),
          '/cotacoes': (context) => const CotacoesPage(),
        },
      ),
    );
  }
}