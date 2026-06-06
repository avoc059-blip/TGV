import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/auth_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB4H5mbiW0oGxDXoLNuNeZ86eQGgaN7FGg",
      authDomain: "tgv-app-70e65.firebaseapp.com",
      projectId: "tgv-app-70e65",
      storageBucket: "tgv-app-70e65.firebasestorage.app",
      messagingSenderId: "905269908152",
      appId: "1:905269908152:web:45bd3f1e317af74356da4d",
    ),
  );
  
  await initializeDateFormatting('fr', null);
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const TransportApp(),
    ),
  );
}
