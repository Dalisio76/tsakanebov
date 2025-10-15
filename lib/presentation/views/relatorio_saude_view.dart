import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/relatorio_saude_controller.dart';

class RelatorioSaudeView extends GetView<RelatorioSaudeController> {
  const RelatorioSaudeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Saúde'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarRegistros,
          ),
        ],
      ),
      body: Column(
        children: [
          // Estatísticas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
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

            if (!temFiltros) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  if (controller.tipoSelecionado.value != null)
                    Chip(
                      label: const Text('Tipo filtrado'),
                      onDeleted: () => controller.filtrarPorTipo(null),
                    ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: controller.limparFiltros,
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Limpar filtros'),
                  ),
                ],
              ),
            );
          }),

          // Lista de eventos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.registros.isEmpty) {
                return const Center(
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
                padding: const EdgeInsets.all(16),
                itemCount: agrupados.length,
                itemBuilder: (context, index) {
                  final tipo = agrupados.keys.elementAt(index);
                  final eventos = agrupados[tipo]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho do grupo
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              eventos.first.iconeCategoria,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
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
                            margin: const EdgeInsets.only(bottom: 8),
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
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (evento.proximaAplicacao != null)
                                    Text(
                                      evento.iconeAlerta,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    evento.descricao,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy')
                                            .format(evento.dataEvento),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      if (evento.custo != null) ...[
                                        const SizedBox(width: 8),
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
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${evento.veterinario}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (evento.proximaAplicacao != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
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
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // Navegar para histórico do animal
                                controller.verHistoricoAnimal(evento.animalId);
                              },
                            ),
                          )),

                      const SizedBox(height: 16),
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
        tooltip: 'Novo Evento',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 4),
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

            // Filtro por período
            const Text('Período', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => SegmentedButton<int>(
                  segments: const [
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

            const SizedBox(height: 16),

            // Filtro por tipo
            const Text('Tipo de Evento',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.tipoSelecionado.value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Todos os tipos',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todos')),
                    ...controller.tiposEvento.map((tipo) => DropdownMenuItem(
                          value: tipo.id,
                          child: Row(
                            children: [
                              Text(tipo.icone, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(tipo.nome),
                            ],
                          ),
                        )),
                  ],
                  onChanged: (value) {
                    controller.filtrarPorTipo(value);
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
                    onPressed: () => Get.back(),
                    child: const Text('Fechar'),
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
