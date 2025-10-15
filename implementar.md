# 💉 RELATÓRIOS DE SAÚDE - VER TODOS OS EVENTOS

## 🎮 CONTROLLER

### **Criar `lib/presentation/controllers/relatorio_saude_controller.dart`:**

```dart
import 'package:get/get.dart';
import '../../data/models/registro_saude_model.dart';
import '../../data/models/tipo_evento_saude_model.dart';
import '../../data/services/registro_saude_service.dart';
import '../../data/services/tipo_evento_saude_service.dart';

class RelatorioSaudeController extends GetxController {
  final RegistroSaudeService _saudeService = RegistroSaudeService();
  final TipoEventoSaudeService _tipoService = TipoEventoSaudeService();

  var registros = <RegistroSaudeModel>[].obs;
  var tiposEvento = <TipoEventoSaudeModel>[].obs;
  var isLoading = false.obs;

  // Filtros
  var tipoSelecionado = Rxn<String>();
  var diasFiltro = 30.obs;

  @override
  void onInit() {
    super.onInit();
    carregarTipos();
    carregarRegistros();
  }

  Future<void> carregarTipos() async {
    try {
      tiposEvento.value = await _tipoService.listarTodos();
    } catch (e) {
      // Silencioso
    }
  }

  Future<void> carregarRegistros() async {
    try {
      isLoading.value = true;
      registros.value = await _saudeService.listarRecentes(
        dias: diasFiltro.value,
      );

      // Aplicar filtro de tipo se selecionado
      if (tipoSelecionado.value != null) {
        registros.value = registros
            .where((r) => r.tipoEventoId == tipoSelecionado.value)
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar registros: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void alterarFiltro(int dias) {
    diasFiltro.value = dias;
    carregarRegistros();
  }

  void filtrarPorTipo(String? tipoId) {
    tipoSelecionado.value = tipoId;
    carregarRegistros();
  }

  void limparFiltros() {
    tipoSelecionado.value = null;
    diasFiltro.value = 30;
    carregarRegistros();
  }

  // Agrupar por tipo
  Map<String, List<RegistroSaudeModel>> get registrosPorTipo {
    final Map<String, List<RegistroSaudeModel>> agrupados = {};

    for (var registro in registros) {
      final tipo = registro.tipoEventoNome ?? 'Outros';
      if (!agrupados.containsKey(tipo)) {
        agrupados[tipo] = [];
      }
      agrupados[tipo]!.add(registro);
    }

    return agrupados;
  }

  // Estatísticas
  int get totalEventos => registros.length;

  double get custoTotal {
    return registros.fold(0.0, (sum, r) => sum + (r.custo ?? 0.0));
  }

  int get totalAnimais {
    return registros.map((r) => r.animalId).toSet().length;
  }
}
```

---

## 🎨 VIEW

### **Criar `lib/presentation/views/relatorio_saude_view.dart`:**

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/relatorio_saude_controller.dart';

class RelatorioSaudeView extends GetView<RelatorioSaudeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Saúde'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.carregarRegistros,
          ),
        ],
      ),
      body: Column(
        children: [
          // Estatísticas
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Eventos',
                      controller.totalEventos.toString(),
                      Icons.medical_services,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Animais',
                      controller.totalAnimais.toString(),
                      Icons.pets,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Custo Total',
                      'R\$ ${controller.custoTotal.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.orange,
                    ),
                  ],
                )),
          ),

          // Filtros ativos
          Obx(() {
            final temFiltros = controller.tipoSelecionado.value != null;

            if (!temFiltros) return SizedBox.shrink();

            return Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  if (controller.tipoSelecionado.value != null)
                    Chip(
                      label: Text('Tipo filtrado'),
                      onDeleted: () => controller.filtrarPorTipo(null),
                    ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: controller.limparFiltros,
                    icon: Icon(Icons.clear_all, size: 18),
                    label: Text('Limpar filtros'),
                  ),
                ],
              ),
            );
          }),

          // Lista de eventos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.registros.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum evento registrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajuste o período ou registre novos eventos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // Agrupar por tipo
              final agrupados = controller.registrosPorTipo;

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: agrupados.length,
                itemBuilder: (context, index) {
                  final tipo = agrupados.keys.elementAt(index);
                  final eventos = agrupados[tipo]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho do grupo
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              eventos.first.iconeCategoria,
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(width: 8),
                            Text(
                              '$tipo (${eventos.length})',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Lista de eventos deste tipo
                      ...eventos.map((evento) => Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Text(
                                  evento.animalBrinco?.substring(0, 1) ?? '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      evento.animalBrinco ?? 'Animal',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (evento.proximaAplicacao != null)
                                    Text(
                                      evento.iconeAlerta,
                                      style: TextStyle(fontSize: 18),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    evento.descricao,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(evento.dataEvento),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      if (evento.custo != null) ...[
                                        SizedBox(width: 8),
                                        Text(
                                          '• R\$ ${evento.custo!.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                      if (evento.veterinario != null) ...[
                                        SizedBox(width: 8),
                                        Text(
                                          '• ${evento.veterinario}',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (evento.proximaAplicacao != null)
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'Próxima: ${DateFormat('dd/MM/yyyy').format(evento.proximaAplicacao!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navegar para histórico do animal
                                Get.toNamed('/historico-saude',
                                    arguments: evento.animalBrinco);
                              },
                            ),
                          )),

                      SizedBox(height: 16),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/saude'),
        child: Icon(Icons.add),
        tooltip: 'Novo Evento',
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  void _mostrarFiltros() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Filtro por período
            Text('Período', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Obx(() => SegmentedButton<int>(
                  segments: [
                    ButtonSegment(value: 7, label: Text('7 dias')),
                    ButtonSegment(value: 30, label: Text('30 dias')),
                    ButtonSegment(value: 90, label: Text('90 dias')),
                    ButtonSegment(value: 365, label: Text('1 ano')),
                  ],
                  selected: {controller.diasFiltro.value},
                  onSelectionChanged: (Set<int> selected) {
                    controller.alterarFiltro(selected.first);
                  },
                )),

            SizedBox(height: 16),

            // Filtro por tipo
            Text('Tipo de Evento',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.tipoSelecionado.value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Todos os tipos',
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    ...controller.tiposEvento.map((tipo) => DropdownMenuItem(
                          value: tipo.id,
                          child: Row(
                            children: [
                              Text(tipo.icone, style: TextStyle(fontSize: 20)),
                              SizedBox(width: 8),
                              Text(tipo.nome),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) {
                    controller.filtrarPorTipo(value);
                  },
                )),

            SizedBox(height: 24),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.limparFiltros();
                      Get.back();
                    },
                    child: Text('Limpar'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Fechar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔗 BINDING

### **Criar `lib/presentation/bindings/relatorio_saude_binding.dart`:**

```dart
import 'package:get/get.dart';
import '../controllers/relatorio_saude_controller.dart';

class RelatorioSaudeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RelatorioSaudeController());
  }
}
```

---

## 🛣️ ADICIONAR ROTA

### **Editar `lib/routes/app_routes.dart`:**

Adicionar:
```dart
static const String RELATORIO_SAUDE = '/relatorio-saude';
```

### **Editar `lib/routes/app_pages.dart`:**

Adicionar import:
```dart
import '../presentation/views/relatorio_saude_view.dart';
import '../presentation/bindings/relatorio_saude_binding.dart';
```

Adicionar rota:
```dart
GetPage(
  name: AppRoutes.RELATORIO_SAUDE,
  page: () => RelatorioSaudeView(),
  binding: RelatorioSaudeBinding(),
),
```

---

## 🏠 ADICIONAR NA HOME

### **Editar `lib/presentation/views/home_view.dart`:**

Substituir o botão "Ver Alertas" por:

```dart
// Botão Relatório de Saúde
SizedBox(
  width: 250,
  child: ElevatedButton.icon(
    onPressed: () => Get.toNamed('/relatorio-saude'),
    icon: Icon(Icons.assignment, size: 24),
    label: Text('Relatório de Saúde', style: TextStyle(fontSize: 16)),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.purple.shade400,
      foregroundColor: Colors.white,
    ),
  ),
),

SizedBox(height: 8),

// Botão Alertas (menor)
SizedBox(
  width: 250,
  child: OutlinedButton.icon(
    onPressed: () => Get.toNamed('/alertas-saude'),
    icon: Icon(Icons.notifications_active, size: 20),
    label: Text('Ver Alertas', style: TextStyle(fontSize: 14)),
    style: OutlinedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 12),
      side: BorderSide(color: Colors.red.shade400, width: 2),
      foregroundColor: Colors.red.shade400,
    ),
  ),
),
```

---

## ✅ CHECKLIST

- [ ] Criar `relatorio_saude_controller.dart`
- [ ] Criar `relatorio_saude_view.dart`
- [ ] Criar `relatorio_saude_binding.dart`
- [ ] Adicionar rota em `app_routes.dart`
- [ ] Adicionar GetPage em `app_pages.dart`
- [ ] Atualizar botões na `home_view.dart`
- [ ] Testar

---

## 🧪 TESTAR

```
1. Home → "Relatório de Saúde"
✅ Ver estatísticas (eventos, animais, custo)
✅ Ver lista agrupada por tipo
✅ Ver todos eventos registrados
✅ Filtrar por tipo
✅ Filtrar por período (7/30/90/365 dias)
```

---

**Crie estes 3 arquivos e edite os outros. Me avise se funcionou!** 📊💉