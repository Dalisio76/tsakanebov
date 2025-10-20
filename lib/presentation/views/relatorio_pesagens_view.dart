import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/pesagem_controller.dart';
import '../widgets/app_drawer.dart';

class RelatorioPesagensView extends GetView<PesagemController> {
  const RelatorioPesagensView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Pesagens'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          // Seletor de mês
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: controller.mesAnterior,
                ),
                Obx(
                  () => Text(
                    controller.formatarMes(controller.mesSelecionado.value),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: controller.proximoMes,
                ),
              ],
            ),
          ),

          // Estatísticas do mês
          Obx(() {
            if (controller.isLoadingRelatorio.value) {
              return const Expanded(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final pesagens = controller.pesagensDoMes;

            if (pesagens.isEmpty) {
              return Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma pesagem registrada neste mês',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Calcular estatísticas
            final totalPesagens = pesagens.length;
            final pesoMedio =
                pesagens.map((p) => p.pesoKg).reduce((a, b) => a + b) /
                    pesagens.length;
            final gmds = pesagens
                .where((p) => p.gmdKg != null)
                .map((p) => p.gmdKg!)
                .toList();
            final gmdMedio = gmds.isEmpty
                ? null
                : gmds.reduce((a, b) => a + b) / gmds.length;

            return Expanded(
              child: Column(
                children: [
                  // Cards de estatísticas
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total',
                            totalPesagens.toString(),
                            Icons.fitness_center,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Peso Médio',
                            '${pesoMedio.toStringAsFixed(1)} kg',
                            Icons.monitor_weight,
                            Colors.green,
                          ),
                        ),
                        if (gmdMedio != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'GMD Médio',
                              '${gmdMedio.toStringAsFixed(3)} kg/dia',
                              Icons.trending_up,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Lista de pesagens
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: controller.carregarPesagensDoMes,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: pesagens.length,
                        itemBuilder: (context, index) {
                          final pesagem = pesagens[index];
                          return _buildPesagemCard(pesagem);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, IconData icon, Color cor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: cor, size: 32),
            const SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesagemCard(pesagem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(Icons.monitor_weight, color: Colors.green.shade700),
        ),
        title: Text(
          pesagem.animalBrinco ?? 'Animal desconhecido',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(pesagem.dataPesagem)),
            if (pesagem.tipoPesagem != null)
              Text(
                pesagem.tipoPesagem!.toUpperCase(),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${pesagem.pesoKg.toStringAsFixed(1)} kg',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (pesagem.gmdKg != null)
              Text(
                'GMD: ${pesagem.gmdKg!.toStringAsFixed(3)} ${pesagem.gmdIcone}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}
