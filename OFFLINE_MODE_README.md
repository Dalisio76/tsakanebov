# Sistema de Modo Offline - Implementação

## ✅ **JÁ IMPLEMENTADO**

### 1. Pacotes Instalados
- `sqflite` - Banco de dados local SQLite
- `path_provider` - Acesso a diretórios do dispositivo
- `connectivity_plus` - Monitoramento de conexão
- `shared_preferences` - Armazenamento de preferências

### 2. Banco de Dados Local (`lib/core/database/local_database.dart`)
- ✅ Tabela `pesagens_offline` - Armazena pesagens offline
- ✅ Tabela `animais_offline` - Armazena novos animais offline
- ✅ Tabela `saude_offline` - Armazena vacinações offline
- ✅ Tabela `animais_cache` - Cache de animais para busca offline
- ✅ Métodos CRUD para todas as tabelas
- ✅ Contadores de dados não sincronizados

### 3. Serviço de Conectividade (`lib/core/services/connectivity_service.dart`)
- ✅ Monitoramento em tempo real da conexão
- ✅ Notificações quando fica online/offline
- ✅ Trigger automático de sincronização ao conectar

### 4. Serviço de Sincronização (`lib/core/services/sync_service.dart`)
- ✅ Sincronização de animais offline → Supabase
- ✅ Sincronização de pesagens offline → Supabase
- ✅ Sincronização de eventos de saúde offline → Supabase
- ✅ Cache de animais para uso offline
- ✅ Limpeza de dados já sincronizados
- ✅ Progresso de sincronização (0-100%)
- ✅ Contador de dados pendentes

---

## ✅ **FASE 2 - IMPLEMENTADO**

### 5. Serviços Atualizados com Suporte Offline

#### A. ✅ `PesagemService` - Lógica offline implementada (`lib/data/services/pesagem_service.dart:13`):
```dart
Future<PesagemModel> criar(PesagemModel pesagem) async {
  final connectivityService = Get.find<ConnectivityService>();

  if (!connectivityService.isOnline) {
    // Salvar offline
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    await LocalDatabase.instance.inserirPesagemOffline({
      'local_id': localId,
      'animal_id': pesagem.animalId,
      'animal_brinco': pesagem.animalBrinco,
      'peso_kg': pesagem.pesoKg,
      'data_pesagem': pesagem.dataPesagem.toIso8601String(),
      'tipo_pesagem': pesagem.tipoPesagem,
      'observacoes': pesagem.observacoes,
      'criado_em': DateTime.now().toIso8601String(),
      'sincronizado': 0,
    });

    // Atualizar contador
    Get.find<SyncService>().atualizarContadorNaoSincronizados();

    return pesagem;
  }

  // Online - salvar no Supabase
  // ... código existente ...
}

// Buscar animal: tentar online, fallback para cache
Future<List<AnimalModel>> buscarPorBrinco(String brinco) async {
  final connectivityService = Get.find<ConnectivityService>();

  if (!connectivityService.isOnline) {
    // Buscar no cache local
    final resultados = await LocalDatabase.instance.buscarAnimaisNoCache(brinco);
    return resultados.map((data) => AnimalModel.fromCacheJson(data)).toList();
  }

  // Online - buscar no Supabase
  // ... código existente ...
}
```

#### B. ✅ `AnimalService` - Lógica offline implementada (`lib/data/services/animal_service.dart:69` e `animal_service.dart:159`):
```dart
Future<AnimalModel> criar(AnimalModel animal) async {
  final connectivityService = Get.find<ConnectivityService>();

  if (!connectivityService.isOnline) {
    // Salvar offline
    final localId = DateTime.now().millisecondsSinceEpoch.toString();
    await LocalDatabase.instance.inserirAnimalOffline({
      'local_id': localId,
      'brinco': animal.brinco,
      'nome': animal.nome,
      'grupo_id': animal.grupoId,
      'pai_id': animal.paiId,
      'mae_id': animal.maeId,
      'sexo': animal.sexo,
      'tipo_pele': animal.tipoPele,
      'raca': animal.raca,
      'data_nascimento': animal.dataNascimento.toIso8601String(),
      'peso_atual_kg': animal.pesoAtualKg,
      'url_imagem': animal.urlImagem,
      'observacoes': animal.observacoes,
      'status': animal.status,
      'criado_em': DateTime.now().toIso8601String(),
      'sincronizado': 0,
    });

    Get.find<SyncService>().atualizarContadorNaoSincronizados();
    return animal;
  }

  // Online - criar no Supabase
  // ... código existente ...
}
```

### 6. ✅ UI - Indicador de Sincronização IMPLEMENTADO

#### A. ✅ Widget de Status de Conexão (`lib/presentation/widgets/sync_indicator.dart`):
- `SyncIndicator`: Badge mostrando status de conexão (verde/laranja/vermelho)
- `SyncButton`: FAB que aparece quando há dados pendentes

#### B. ✅ Adicionado aos AppBars:
- `PesagemView` (lib/presentation/views/pesagem_view.dart:15)
- `AnimalFormView` (lib/presentation/views/animal_form_view.dart:15)
- `DashboardView` (lib/presentation/views/dashboard_view.dart:16)

#### C. ✅ Botão de Sincronização Manual:
- Adicionado como FloatingActionButton no Dashboard

### 7. ✅ Inicialização dos Serviços IMPLEMENTADO (`lib/main.dart:22`)

```dart
// Inicializar serviços offline (permanentes)
Get.put(ConnectivityService(), permanent: true);
Get.put(SyncService(), permanent: true);

// Cachear animais para uso offline (em background)
Future.delayed(const Duration(seconds: 2), () async {
  await Get.find<SyncService>().cacheAnimaisParaOffline();
});
```

---

#### C. ✅ `RegistroSaudeService` - Lógica offline implementada (`lib/data/services/registro_saude_service.dart:13`):
- Método `criar()` verifica conectividade
- Salva eventos de saúde localmente quando offline
- Atualiza contador de dados não sincronizados

#### D. ✅ `SaudeView` - SyncIndicator adicionado (`lib/presentation/views/saude_view.dart:15`)

---

## ⏳ **PENDENTE - PRÓXIMOS PASSOS**

### 8. Testes do Sistema Offline

**Recomendado**: Realizar testes completos do sistema offline em dispositivo real:
1. ✅ Desconectar internet e registrar pesagens
2. ✅ Desconectar internet e cadastrar novos animais
3. ✅ Desconectar internet e registrar eventos de saúde/vacinações
4. ✅ Reconectar e verificar sincronização automática
5. ✅ Testar sincronização manual com botão
6. ✅ Verificar cache de animais para busca offline
7. ⚠️ Testar com volume grande de dados (100+ registros offline)
8. ⚠️ Testar cenários de falha (conexão intermitente)

---

## ⚠️ **REMOVIDO DA DOCUMENTAÇÃO (SEÇÕES ANTIGAS)**

### UI - Indicador de Sincronização (IMPLEMENTADO - ver acima)

#### Widget de Status de Conexão (IMPLEMENTADO `lib/presentation/widgets/sync_indicator.dart`):
```dart
class SyncIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectivityService = Get.find<ConnectivityService>();
    final syncService = Get.find<SyncService>();

    return Obx(() {
      final isOnline = connectivityService.isOnline;
      final isSyncing = syncService.isSyncing.value;
      final pendentes = syncService.dadosNaoSincronizados.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isOnline ? Colors.green.shade100 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOnline ? Icons.cloud_done : Icons.cloud_off,
              size: 16,
              color: isOnline ? Colors.green : Colors.orange,
            ),
            SizedBox(width: 6),
            Text(
              isOnline
                ? (isSyncing ? 'Sincronizando...' : 'Online')
                : 'Offline ($pendentes pendentes)',
              style: TextStyle(
                fontSize: 12,
                color: isOnline ? Colors.green.shade900 : Colors.orange.shade900,
              ),
            ),
            if (isSyncing)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.green),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
```

#### B. Adicionar ao AppBar das views principais:
```dart
appBar: AppBar(
  title: Text('Registrar Pesagem'),
  actions: [
    Padding(
      padding: EdgeInsets.only(right: 16),
      child: Center(child: SyncIndicator()),
    ),
  ],
)
```

#### C. Botão de Sincronização Manual:
```dart
FloatingActionButton(
  onPressed: () {
    Get.find<SyncService>().sincronizarTudo();
  },
  child: Icon(Icons.sync),
)
```


---

## 🎯 **FUNCIONALIDADES IMPLEMENTADAS**

O sistema agora possui:

1. **✅ Trabalho 100% offline no campo**
   - ✅ Registrar pesagens sem internet
   - ✅ Cadastrar novos animais sem internet
   - ✅ Registrar vacinações/eventos de saúde sem internet

2. **✅ Busca offline de animais**
   - Cache local de todos os animais
   - Busca por brinco funciona offline

3. **✅ Sincronização Automática**
   - Detecta quando volta online
   - Sincroniza todos os dados automaticamente
   - Notifica usuário do progresso

4. **✅ Sincronização Manual**
   - Botão para forçar sincronização
   - Útil após muitos registros offline

5. **✅ Indicadores Visuais**
   - Badge mostrando Online/Offline
   - Contador de dados pendentes
   - Barra de progresso durante sync

6. **✅ Segurança dos Dados**
   - Dados não são perdidos se fechar app
   - Tentativas automáticas de sync
   - Limpeza apenas após confirmação

---

## 📝 **NOTAS IMPORTANTES**

- O SQLite funciona apenas em mobile/desktop (não web)
- Para web, considerar IndexedDB no futuro
- Testar bastante em campo sem internet
- Validar sincronização com muitos dados
- Considerar limite de dados no cache (ex: últimos 1000 animais)

---

## 🔧 **COMANDOS ÚTEIS**

```bash
# Ver dados não sincronizados
flutter pub run sqflite:sqflite
SELECT * FROM pesagens_offline WHERE sincronizado = 0;

# Limpar banco offline (dev only)
DELETE FROM pesagens_offline;
DELETE FROM animais_offline;
DELETE FROM saude_offline;
```
