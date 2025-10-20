import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ConnectivityService>(
      builder: (connectivityService) {
        final isOnline = connectivityService.isOnline;

        return GetX<SyncService>(
          builder: (syncService) {
            final isSyncing = syncService.isSyncing.value;
            final pendentes = syncService.dadosNaoSincronizados.value;

            return GestureDetector(
              onTap: () {
                if (isOnline && pendentes > 0 && !isSyncing) {
                  syncService.sincronizarTudo();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOnline
                      ? (pendentes > 0
                          ? Colors.orange.shade100
                          : Colors.green.shade100)
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline
                        ? (pendentes > 0
                            ? Colors.orange.shade300
                            : Colors.green.shade300)
                        : Colors.red.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: isOnline
                          ? (pendentes > 0 ? Colors.orange : Colors.green)
                          : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getStatusText(isOnline, isSyncing, pendentes),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOnline
                            ? (pendentes > 0
                                ? Colors.orange.shade900
                                : Colors.green.shade900)
                            : Colors.red.shade900,
                      ),
                    ),
                    if (isSyncing) ...[
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getStatusText(bool isOnline, bool isSyncing, int pendentes) {
    if (isSyncing) {
      return 'Sincronizando...';
    }

    if (!isOnline) {
      return pendentes > 0 ? 'Offline ($pendentes)' : 'Offline';
    }

    return pendentes > 0 ? 'Pendentes: $pendentes' : 'Sincronizado';
  }
}

class SyncButton extends StatelessWidget {
  const SyncButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ConnectivityService>(
      builder: (connectivityService) {
        final isOnline = connectivityService.isOnline;

        return GetX<SyncService>(
          builder: (syncService) {
            final isSyncing = syncService.isSyncing.value;
            final pendentes = syncService.dadosNaoSincronizados.value;

            if (!isOnline || pendentes == 0) {
              return const SizedBox.shrink();
            }

            return FloatingActionButton.extended(
              onPressed: isSyncing ? null : () => syncService.sincronizarTudo(),
              backgroundColor: Colors.orange,
              icon: isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: Text(
                isSyncing ? 'Sincronizando...' : 'Sincronizar ($pendentes)',
              ),
            );
          },
        );
      },
    );
  }
}
