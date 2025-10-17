import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/app_drawer.dart';

class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.carregarDashboard,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.stats.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Erro ao carregar dados'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.carregarDashboard,
                  child: Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregarDashboard,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPIs Principais
                _buildKPIsSection(),
                SizedBox(height: 24),

                // Gráficos de Linha (UA/ha e @/ha)
                _buildGraficosLinha(),
                SizedBox(height: 24),

                // Gráficos de Pizza
                _buildGraficosPizza(),
                SizedBox(height: 24),

                // Alertas
                _buildAlertasSection(),
                SizedBox(height: 24),

                // Reprodução
                _buildReproducaoSection(),
                SizedBox(height: 24),

                // Custos
                _buildCustosSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // KPIs Principais
  Widget _buildKPIsSection() {
    final stats = controller.stats.value!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                icon: Icons.pets,
                label: 'ANIMAIS',
                valor: stats.animaisAtivos.toString(),
                cor: Colors.green,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                icon: Icons.monitor_weight,
                label: 'PESO TOTAL',
                valor: '${NumberFormat('#,##0', 'pt_BR').format(stats.pesoTotalKg)} kg',
                cor: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                icon: Icons.trending_up,
                label: 'GMD MÉDIO',
                valor: '${stats.gmdMedio.toStringAsFixed(3)} kg/dia',
                cor: Colors.orange,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                icon: Icons.attach_money,
                label: '@ BOI/B3',
                valor: 'R\$ ${stats.valorArrobaAtual.toStringAsFixed(2)}',
                cor: Colors.purple,
                subtitle: 'Total: ${controller.formatarMoeda(stats.valorTotalRebanho)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required IconData icon,
    required String label,
    required String valor,
    required Color cor,
    String? subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              Spacer(),
            ],
          ),
          SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          if (subtitle != null) ...[
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Gráficos de Linha (UA/ha e @/ha)
  Widget _buildGraficosLinha() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildGraficoUAHa(),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildGraficoArrobaHa(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGraficoUAHa() {
    double uaHa = controller.unidadeAnimalPorHa;
    double mediaMercado = 1.2; // Média do mercado (exemplo)

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unidade Animal / ha',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final meses = ['Jul', 'Ago', 'Set', 'Out'];
                        if (value.toInt() >= 0 && value.toInt() < meses.length) {
                          return Text(meses[value.toInt()], style: TextStyle(fontSize: 10));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 2,
                lineBarsData: [
                  // Linha da fazenda
                  LineChartBarData(
                    spots: [
                      FlSpot(0, uaHa),
                      FlSpot(1, uaHa * 0.95),
                      FlSpot(2, uaHa * 1.05),
                      FlSpot(3, uaHa),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Linha média mercado
                  LineChartBarData(
                    spots: [
                      FlSpot(0, mediaMercado),
                      FlSpot(1, mediaMercado),
                      FlSpot(2, mediaMercado),
                      FlSpot(3, mediaMercado),
                    ],
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegenda(Colors.green, 'Minha fazenda (${uaHa.toStringAsFixed(2)})'),
              SizedBox(width: 12),
              _buildLegenda(Colors.blue, 'Média Mercado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoArrobaHa() {
    double arrobaHa = controller.ganhoArrobaPorHa;
    double mediaMercado = 6.0; // Média do mercado (exemplo)

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ganho @ / ha',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final meses = ['Ago', 'Set', 'Out'];
                        if (value.toInt() >= 0 && value.toInt() < meses.length) {
                          return Text(meses[value.toInt()], style: TextStyle(fontSize: 10));
                        }
                        return Text('');
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 10,
                lineBarsData: [
                  // Linha da fazenda
                  LineChartBarData(
                    spots: [
                      FlSpot(0, arrobaHa * 0.9),
                      FlSpot(1, arrobaHa),
                      FlSpot(2, arrobaHa * 1.1),
                    ],
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  // Linha média mercado
                  LineChartBarData(
                    spots: [
                      FlSpot(0, mediaMercado),
                      FlSpot(1, mediaMercado),
                      FlSpot(2, mediaMercado),
                    ],
                    isCurved: false,
                    color: Colors.blue,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegenda(Colors.green, 'Minha fazenda (${arrobaHa.toStringAsFixed(1)})'),
              SizedBox(width: 12),
              _buildLegenda(Colors.blue, 'Média Mercado'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegenda(Color cor, String texto) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(texto, style: TextStyle(fontSize: 10)),
      ],
    );
  }

  // Gráficos de Pizza
  Widget _buildGraficosPizza() {
    final stats = controller.stats.value!;
    final grupos = controller.gruposStats;

    return Column(
      children: [
        // Linha 1: Sexo e Lotes
        Row(
          children: [
            Expanded(child: _buildGraficoPizzaSexo()),
            SizedBox(width: 12),
            Expanded(child: _buildGraficoPizzaLotes()),
          ],
        ),
        SizedBox(height: 12),
        // Linha 2: Peso por Lote
        _buildGraficoPizzaPesoLotes(),
      ],
    );
  }

  Widget _buildGraficoPizzaSexo() {
    final stats = controller.stats.value!;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animais por Sexo',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: stats.totalFemeas.toDouble(),
                    title: '${stats.percentualFemeas}%',
                    color: Colors.teal,
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: stats.totalMachos.toDouble(),
                    title: '${stats.percentualMachos}%',
                    color: Colors.blue,
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegenda(Colors.teal, 'Fêmeas (${stats.totalFemeas})'),
              SizedBox(width: 12),
              _buildLegenda(Colors.blue, 'Machos (${stats.totalMachos})'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPizzaLotes() {
    final grupos = controller.gruposStats;

    if (grupos.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: Text('Sem dados de grupos')),
      );
    }

    List<Color> cores = [
      Colors.lightBlue.shade300,
      Colors.grey.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animais por Lote',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: grupos
                    .asMap()
                    .entries
                    .map((entry) {
                      int idx = entry.key;
                      var grupo = entry.value;
                      return PieChartSectionData(
                        value: grupo.totalAnimais.toDouble(),
                        title: grupo.totalAnimais.toString(),
                        color: cores[idx % cores.length],
                        radius: 70,
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    })
                    .toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: grupos
                .asMap()
                .entries
                .map((entry) {
                  int idx = entry.key;
                  var grupo = entry.value;
                  return _buildLegenda(
                    cores[idx % cores.length],
                    '${grupo.grupoNome} (${grupo.totalAnimais})',
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGraficoPizzaPesoLotes() {
    final grupos = controller.gruposStats;

    if (grupos.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(child: Text('Sem dados de grupos')),
      );
    }

    List<Color> cores = [
      Colors.lightBlue.shade300,
      Colors.grey.shade400,
      Colors.red.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
    ];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peso Total por Lote',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: grupos
                    .asMap()
                    .entries
                    .map((entry) {
                      int idx = entry.key;
                      var grupo = entry.value;
                      return PieChartSectionData(
                        value: grupo.pesoTotalKg,
                        title: '${(grupo.pesoTotalKg / 1000).toStringAsFixed(1)}t',
                        color: cores[idx % cores.length],
                        radius: 90,
                        titleStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    })
                    .toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: grupos
                .asMap()
                .entries
                .map((entry) {
                  int idx = entry.key;
                  var grupo = entry.value;
                  return _buildLegenda(
                    cores[idx % cores.length],
                    '${grupo.grupoNome} (${(grupo.pesoTotalKg / 1000).toStringAsFixed(1)}t)',
                  );
                })
                .toList(),
          ),
        ],
      ),
    );
  }

  // Alertas
  Widget _buildAlertasSection() {
    final stats = controller.stats.value!;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'Alertas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildAlertaItem(
            '🔴 Vacinas Vencidas',
            stats.vacinasVencidas.toString(),
            stats.vacinasVencidas > 0 ? Colors.red : Colors.green,
          ),
          SizedBox(height: 8),
          _buildAlertaItem(
            '🟡 Vacinas Próximas (7 dias)',
            stats.vacinasProximas.toString(),
            stats.vacinasProximas > 0 ? Colors.orange : Colors.green,
          ),
          SizedBox(height: 8),
          _buildAlertaItem(
            '⚖️ Animais sem Pesagem (30+ dias)',
            stats.animaisSemPesagem.toString(),
            stats.animaisSemPesagem > 0 ? Colors.orange : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertaItem(String label, String valor, Color cor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: cor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            valor,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Reprodução
  Widget _buildReproducaoSection() {
    final stats = controller.stats.value!;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pregnant_woman, color: Colors.pink),
              SizedBox(width: 8),
              Text(
                'Reprodução',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  '🤰 Fêmeas Prenhas',
                  stats.femeasPrenhas.toString(),
                  Colors.pink,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  '🍼 Partos Previstos (30 dias)',
                  stats.partosPrevistos30dias.toString(),
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Custos
  Widget _buildCustosSection() {
    final stats = controller.stats.value!;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_money, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Custos (últimos 12 meses)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  '💰 Custo Total',
                  controller.formatarMoeda(stats.custoTotal),
                  Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  '🐄 Custo/Animal',
                  controller.formatarMoeda(stats.custoPorAnimal),
                  Colors.indigo,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  '📦 Custo/@',
                  controller.formatarMoeda(stats.custoPorArroba),
                  Colors.cyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String valor, Color cor) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
