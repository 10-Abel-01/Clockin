import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:Clockin/core/routes/route_app.dart';
import 'package:Clockin/utils/logger.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variabel dari asset .env
  try {
    await dotenv.load(fileName: ".env");
    Log.d("Environment file loaded successfully");
    Log.d("API_URL: ${dotenv.env['API_URL']}");
    Log.d("IMAGE_URL: ${dotenv.env['IMAGE_URL']}");
  } catch (e) {
    Log.d("Failed to load environment file: $e");
  }

  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clockin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: RouteApp.initial,
      routes: RouteApp.routes,
    );
  }
}
