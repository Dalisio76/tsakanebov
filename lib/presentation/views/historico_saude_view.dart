import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/historico_saude_controller.dart';

class HistoricoSaudeView extends GetView<HistoricoSaudeController> {
  const HistoricoSaudeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Saúde'),
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
              color: Colors.blue.shade50,
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
                          _buildInfoChip(
                            'Total de Eventos',
                            '${controller.registros.length}',
                            Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            'Custo Total',
                            'R\$ ${controller.custoTotal.value.toStringAsFixed(2)}',
                            Colors.green,
                          ),
                        ],
                      )),
                ],
              ),
            ),

          // Lista de registros
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
                      Icon(Icons.medical_services_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum evento registrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Registre vacinas e procedimentos',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.registros.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final registro = controller.registros[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ExpansionTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            registro.iconeCategoria,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              registro.tipoEventoNome ?? registro.descricao,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (registro.proximaAplicacao != null)
                            Text(
                              registro.iconeAlerta,
                              style: const TextStyle(fontSize: 20),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(registro.dataEvento),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (registro.custo != null)
                            Text(
                              'R\$ ${registro.custo!.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                  'Descrição', registro.descricao),
                              if (registro.veterinario != null)
                                _buildDetailRow('Veterinário',
                                    registro.veterinario!),
                              if (registro.proximaAplicacao != null)
                                _buildDetailRow(
                                  'Próxima Aplicação',
                                  '${DateFormat('dd/MM/yyyy').format(registro.proximaAplicacao!)} ${registro.iconeAlerta}',
                                ),
                              if (registro.diasAteProxima != null)
                                _buildDetailRow(
                                  'Dias Restantes',
                                  registro.diasAteProxima! >= 0
                                      ? '${registro.diasAteProxima} dias'
                                      : 'Vencido há ${registro.diasAteProxima!.abs()} dias',
                                ),
                              if (registro.observacoes != null &&
                                  registro.observacoes!.isNotEmpty)
                                _buildDetailRow(
                                    'Observações', registro.observacoes!),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
