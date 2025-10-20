import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final _isOnline = true.obs;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  bool get isOnline => _isOnline.value;
  RxBool get isOnlineStream => _isOnline;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('❌ Erro ao verificar conectividade: $e');
      _isOnline.value = false;
    }
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    // Considera online se houver qualquer tipo de conexão
    final hasConnection =
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet;

    if (_isOnline.value != hasConnection) {
      _isOnline.value = hasConnection;

      if (hasConnection) {
        print('🟢 ONLINE - Conexão restaurada');
        Get.snackbar(
          '🟢 Online',
          'Conexão com internet restaurada',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
        // Trigger sincronização automática após delay
        Future.delayed(const Duration(seconds: 1), () {
          try {
            if (Get.isRegistered<dynamic>(tag: 'SyncService')) {
              final syncService = Get.find(tag: 'SyncService');
              if (syncService != null) {
                (syncService as dynamic).sincronizarTudo();
              }
            }
          } catch (e) {
            print('⚠️ SyncService ainda não registrado');
          }
        });
      } else {
        print('🔴 OFFLINE - Sem conexão com internet');
        Get.snackbar(
          '🔴 Modo Offline',
          'Trabalhando sem internet. Dados serão sincronizados quando conectar.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
