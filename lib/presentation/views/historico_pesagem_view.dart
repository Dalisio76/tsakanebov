import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/historico_pesagem_controller.dart';

class HistoricoPesagemView extends GetView<HistoricoPesagemController> {
  const HistoricoPesagemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Pesagens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarHistorico,
          ),
        ],
      ),
      body: Column(
        children: [
          // Header com informações do animal
          if (controller.animal != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: controller.animal!.sexo == 'M'
                            ? Colors.blue
                            : Colors.pink,
                        child: Text(
                          controller.animal!.sexo == 'M' ? '♂️' : '♀️',
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.animal!.brinco,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (controller.animal!.nome != null)
                              Text(controller.animal!.nome!,
                                  style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Row(
                        children: [
                          if (controller.animal!.pesoAtualKg != null)
                            _buildInfoChip(
                              'Peso Atual',
                              '${controller.animal!.pesoAtualKg!.toStringAsFixed(1)} kg',
                              Colors.blue,
                            ),
                          const SizedBox(width: 8),
                          if (controller.gmdMedio.value != null)
                            _buildInfoChip(
                              'GMD Médio',
                              '${controller.gmdMedio.value!.toStringAsFixed(3)} kg/dia',
                              Colors.green,
                            ),
                        ],
                      )),
                ],
              ),
            ),

          // Lista de pesagens
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.pesagens.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma pesagem registrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Registre a primeira pesagem deste animal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.pesagens.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final pesagem = controller.pesagens[index];
                  final isFirst = index == 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    color: isFirst ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isFirst
                              ? Colors.green.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              pesagem.pesoKg.toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'kg',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(pesagem.dataPesagem),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isFirst) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Atual',
                                  style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.green,
                              labelStyle: const TextStyle(color: Colors.white),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pesagem.gmdKg != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(pesagem.gmdIcone),
                                const SizedBox(width: 4),
                                Text('GMD: ${pesagem.gmdFormatado}'),
                              ],
                            ),
                          ],
                          if (pesagem.diasDesdeUltima != null)
                            Text(
                                '${pesagem.diasDesdeUltima} dias desde última',
                                style: const TextStyle(fontSize: 12)),
                          if (pesagem.ganhoPeriodoKg != null)
                            Text(
                                'Ganho: ${pesagem.ganhoPeriodoKg!.toStringAsFixed(1)} kg',
                                style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      trailing: pesagem.tipoPesagem != null &&
                              pesagem.tipoPesagem != 'rotina'
                          ? Chip(
                              label:
                                  Text(pesagem.tipoPesagem!.capitalize!),
                              backgroundColor: Colors.orange.shade100,
                            )
                          : null,
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/pesagem'),
        tooltip: 'Nova Pesagem',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
