import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tsakanebov/routes/app_pages.dart';
import 'package:tsakanebov/routes/app_routes.dart';
import 'core/config/supabase_config.dart';
import 'core/constants/app_constants.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/sync_service.dart';
import 'presentation/bindings/auth_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Inicializar serviços offline (permanentes)
  Get.put(ConnectivityService(), permanent: true);
  Get.put(SyncService(), permanent: true);

  // Cachear animais para uso offline (em background)
  Future.delayed(const Duration(seconds: 2), () async {
    try {
      if (Get.isRegistered<SyncService>()) {
        await Get.find<SyncService>().cacheAnimaisParaOffline();
        print('✅ Cache de animais criado com sucesso');
      }
    } catch (e) {
      print('⚠️ Erro ao cachear animais: $e');
    }
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      initialBinding: AuthBinding(),
      initialRoute: AppRoutes.LOGIN,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      locale: const Locale('pt', 'BR'),
    );
  }
}
