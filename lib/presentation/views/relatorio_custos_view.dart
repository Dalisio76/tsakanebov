import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/relatorio_custos_controller.dart';

class RelatorioCustosView extends GetView<RelatorioCustosController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Custos'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: controller.exportarRelatorio,
            tooltip: 'Exportar',
          ),
        ],
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
                            _buildPeriodoChip('7', '7 dias'),
                            _buildPeriodoChip('30', '30 dias'),
                            _buildPeriodoChip('90', '90 dias'),
                            _buildPeriodoChip('365', '1 ano'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Card de Total
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade500],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Gasto',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        controller.totalFormatado,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Últimos ${controller.periodoSelecionado.value} dias',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Por Categoria
                Text(
                  'Gastos por Categoria',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                if (controller.estatisticasPorCategoria.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Nenhuma despesa registrada neste período',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.estatisticasPorCategoria.entries.map(
                    (entry) => _buildCategoriaCard(
                      entry.key,
                      entry.value,
                      controller.totalGeral.value,
                    ),
                  ),
                SizedBox(height: 24),

                // Despesas Detalhadas
                Text(
                  'Despesas Detalhadas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                ...controller.despesasAgrupadas.entries.map(
                  (entry) => _buildGrupoCard(entry.key, entry.value),
                ),
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

  Widget _buildCategoriaCard(String categoria, double valor, double total) {
    final percentual = (valor / total * 100);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoria,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: percentual / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${percentual.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrupoCard(String categoria, List despesas) {
    final total = despesas.fold(0.0, (sum, d) => sum + d.valor);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          categoria,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')} • ${despesas.length} ${despesas.length == 1 ? 'despesa' : 'despesas'}',
          style: TextStyle(color: Colors.green.shade700),
        ),
        children: despesas.map<Widget>((despesa) {
          return ListTile(
            dense: true,
            title: Text(despesa.descricao),
            subtitle: Text(despesa.dataFormatada),
            trailing: Text(
              despesa.valorFormatado,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
