import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../controllers/animais_controller.dart';
import '../widgets/app_drawer.dart';

class AnimaisView extends GetView<AnimaisController> {
  const AnimaisView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animais'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _mostrarFiltros(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarAnimais,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por brinco...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: controller.buscarPorBrinco,
            ),
          ),

          // Chips de filtros ativos
          Obx(() {
            final temFiltros = controller.grupoSelecionado.value != null ||
                controller.sexoSelecionado.value != null;

            if (!temFiltros) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (controller.grupoSelecionado.value != null)
                    Chip(
                      label: const Text('Grupo filtrado'),
                      onDeleted: () {
                        controller.grupoSelecionado.value = null;
                        controller.carregarAnimais();
                      },
                    ),
                  if (controller.sexoSelecionado.value != null)
                    Chip(
                      label: Text(
                          'Sexo: ${controller.sexoSelecionado.value == "M" ? "Macho" : "Fêmea"}'),
                      onDeleted: () {
                        controller.sexoSelecionado.value = null;
                        controller.carregarAnimais();
                      },
                    ),
                  TextButton.icon(
                    onPressed: controller.limparFiltros,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpar tudo'),
                  ),
                ],
              ),
            );
          }),

          // Lista de animais
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.animais.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pets, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum animal encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.irParaCriar,
                        icon: const Icon(Icons.add),
                        label: const Text('Cadastrar Primeiro Animal'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.animais.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final animal = controller.animais[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: animal.sexo == 'M'
                            ? Colors.blue.shade100
                            : Colors.pink.shade100,
                        child: Text(
                          animal.sexo == 'M' ? '♂️' : '♀️',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            animal.brinco,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (animal.nome != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              animal.nome!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (animal.grupoNome != null)
                            Text('📁 ${animal.grupoNome}'),
                          if (animal.idadeMeses != null)
                            Text('📅 ${animal.idadeMeses} meses'),
                          if (animal.pesoAtualKg != null)
                            Text(
                                '⚖️ ${animal.pesoAtualKg!.toStringAsFixed(1)} kg'),
                          if (animal.paiBrinco != null ||
                              animal.maeBrinco != null)
                            Text(
                              '👨‍👩‍👦 ${animal.paiBrinco ?? "?"} × ${animal.maeBrinco ?? "?"}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'pesar',
                            child: Row(
                              children: [
                                Icon(Icons.monitor_weight, size: 20),
                                SizedBox(width: 8),
                                Text('Pesar Animal'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'historico',
                            child: Row(
                              children: [
                                Icon(Icons.timeline, size: 20),
                                SizedBox(width: 8),
                                Text('Histórico de Peso'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'saude',
                            child: Row(
                              children: [
                                Icon(Icons.medical_services, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Registrar Saúde'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'historico_saude',
                            child: Row(
                              children: [
                                Icon(Icons.history, size: 20),
                                SizedBox(width: 8),
                                Text('Histórico de Saúde'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'detalhes',
                            child: Row(
                              children: [
                                Icon(Icons.info, size: 20),
                                SizedBox(width: 8),
                                Text('Detalhes'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'abate',
                            child: Row(
                              children: [
                                Icon(Icons.restaurant,
                                    size: 20, color: Colors.brown),
                                SizedBox(width: 8),
                                Text('Marcar para Abate',
                                    style: TextStyle(color: Colors.brown)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'deletar',
                            child: Row(
                              children: [
                                Icon(Icons.delete,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Marcar como morto',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'saude') {
                            Get.toNamed('/saude');
                          } else if (value == 'historico_saude') {
                            Get.toNamed('/historico-saude', arguments: animal);
                          } else if (value == 'pesar') {
                            Get.toNamed('/pesagem');
                          } else if (value == 'historico') {
                            Get.toNamed('/historico-pesagem', arguments: animal);
                          } else if (value == 'detalhes') {
                            controller.irParaDetalhes(animal);
                          } else if (value == 'editar') {
                            controller.irParaEditar(animal);
                          } else if (value == 'abate') {
                            _marcarParaAbate(animal);
                          } else if (value == 'deletar') {
                            controller.deletarAnimal(animal);
                          }
                        },
                      ),
                      onTap: () => controller.irParaDetalhes(animal),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.irParaCriar,
        tooltip: 'Novo Animal',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _mostrarFiltros(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Filtro por Grupo
            const Text('Grupo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.grupoSelecionado.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Todos os grupos',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...controller.grupos.map((grupo) => DropdownMenuItem(
                          value: grupo.id,
                          child: Text(grupo.nome),
                        )),
                  ],
                  onChanged: (value) {
                    controller.grupoSelecionado.value = value;
                  },
                )),

            const SizedBox(height: 16),

            // Filtro por Sexo
            const Text('Sexo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.sexoSelecionado.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Todos',
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'M', child: Text('♂️ Machos')),
                    DropdownMenuItem(value: 'F', child: Text('♀️ Fêmeas')),
                  ],
                  onChanged: (value) {
                    controller.sexoSelecionado.value = value;
                  },
                )),

            const SizedBox(height: 24),

            // Botões
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.limparFiltros();
                      Get.back();
                    },
                    child: const Text('Limpar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.aplicarFiltros();
                      Get.back();
                    },
                    child: const Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _marcarParaAbate(AnimalModel animal) {
    Get.defaultDialog(
      title: 'Marcar para Abate',
      middleText: 'Tem certeza que deseja marcar o animal ${animal.brinco} para abate?',
      textConfirm: 'Sim, marcar',
      textCancel: 'Cancelar',
      confirmTextColor: Colors.white,
      buttonColor: Colors.brown,
      onConfirm: () async {
        Get.back(); // Fecha diálogo
        await controller.marcarParaAbate(animal);
      },
    );
  }
}
