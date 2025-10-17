import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/relatorio_reproducao_controller.dart';

class RelatorioReproducaoView extends GetView<RelatorioReproducaoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Reprodução'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.carregarDados,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seletor de Período
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Período',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildPeriodoChip('30', '30 dias'),
                            _buildPeriodoChip('90', '90 dias'),
                            _buildPeriodoChip('180', '6 meses'),
                            _buildPeriodoChip('365', '1 ano'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Cards de Estatísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Coberturas',
                        controller.totalCoberturas.value.toString(),
                        Icons.favorite,
                        Colors.pink,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Taxa Prenhez',
                        controller.taxaPrenheFormatada,
                        Icons.pregnant_woman,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Monta Natural',
                        controller.montaNatural.value.toString(),
                        Icons.pets,
                        Colors.brown,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Inseminação',
                        controller.inseminacao.value.toString(),
                        Icons.science,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Prenhas Ativas
                Text(
                  'Prenhas Ativas (${controller.prenhasAtivas.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                if (controller.prenhasAtivas.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Nenhuma fêmea prenha no momento',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.prenhasAtivas.map(
                    (prenha) => _buildPrenhaCard(prenha),
                  ),
                SizedBox(height: 24),

                // Estatísticas de Partos
                Obx(() {
                  if (controller.estatisticasPartos.isEmpty) {
                    return SizedBox();
                  }

                  final stats = controller.estatisticasPartos;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas de Partos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildStatRow(
                                'Total de Partos',
                                stats['total_partos']?.toString() ?? '0',
                              ),
                              Divider(),
                              _buildStatRow(
                                'Bezerros Vivos',
                                stats['bezerros_vivos']?.toString() ?? '0',
                                valueColor: Colors.green,
                              ),
                              _buildStatRow(
                                'Bezerros Mortos',
                                stats['bezerros_mortos']?.toString() ?? '0',
                                valueColor: Colors.red,
                              ),
                              _buildStatRow(
                                'Taxa de Sobrevivência',
                                controller.taxaSobrevivenciaFormatada,
                                valueColor: Colors.blue,
                              ),
                              Divider(),
                              _buildStatRow(
                                'Partos Normais',
                                stats['partos_normais']?.toString() ?? '0',
                              ),
                              _buildStatRow(
                                'Partos Assistidos',
                                stats['partos_assistidos']?.toString() ?? '0',
                              ),
                              _buildStatRow(
                                'Cesarianas',
                                stats['partos_cesariana']?.toString() ?? '0',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeriodoChip(String valor, String label) {
    return Obx(() => ChoiceChip(
          label: Text(label),
          selected: controller.periodoSelecionado.value == valor,
          onSelected: (selected) {
            if (selected) {
              controller.mudarPeriodo(valor);
            }
          },
        ));
  }

  Widget _buildStatCard(
      String titulo, String valor, IconData icone, Color cor) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icone, size: 32, color: cor),
            SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrenhaCard(prenha) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.pregnant_woman, color: Colors.blue.shade700),
        ),
        title: Text(prenha.femeaBrinco ?? 'Desconhecida'),
        subtitle: Text('Previsão: ${prenha.dataPrevistaFormatada}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: prenha.diasRestantes != null && prenha.diasRestantes! <= 7
                ? Colors.red.shade50
                : prenha.diasRestantes != null && prenha.diasRestantes! <= 30
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            prenha.statusAlerta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
