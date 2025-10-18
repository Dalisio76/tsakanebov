import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/app_drawer.dart';

class RelatoriosView extends StatelessWidget {
  const RelatoriosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Relatórios'),
        backgroundColor: Colors.indigo,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildRelatorioCard(
              icon: Icons.pets,
              titulo: 'Relatório de Animais',
              cor: Colors.blue,
              onTap: () {
                Get.snackbar(
                  'Em Desenvolvimento',
                  'Relatório de Animais em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            _buildRelatorioCard(
              icon: Icons.monitor_weight,
              titulo: 'Histórico de Pesagens',
              cor: Colors.orange,
              onTap: () => Get.toNamed('/historico-pesagem'),
            ),
            _buildRelatorioCard(
              icon: Icons.medical_services,
              titulo: 'Relatório de Saúde',
              cor: Colors.red,
              onTap: () => Get.toNamed('/relatorio-saude'),
            ),
            _buildRelatorioCard(
              icon: Icons.attach_money,
              titulo: 'Relatório Financeiro',
              cor: Colors.green,
              onTap: () => Get.toNamed('/relatorio-custos'),
            ),
            _buildRelatorioCard(
              icon: Icons.pregnant_woman,
              titulo: 'Relatório de Reprodução',
              cor: Colors.pink,
              onTap: () => Get.toNamed('/relatorio-reproducao'),
            ),
            _buildRelatorioCard(
              icon: Icons.trending_up,
              titulo: 'Evolução do Rebanho',
              cor: Colors.purple,
              onTap: () {
                Get.snackbar(
                  'Em Desenvolvimento',
                  'Evolução do Rebanho em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
            _buildRelatorioCard(
              icon: Icons.food_bank,
              titulo: 'Relatório de Abate',
              cor: Colors.brown,
              onTap: () => Get.toNamed('/animais-abate'),
            ),
            _buildRelatorioCard(
              icon: Icons.compare_arrows,
              titulo: 'Movimentações',
              cor: Colors.teal,
              onTap: () {
                Get.snackbar(
                  'Em Desenvolvimento',
                  'Movimentações em breve!',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatorioCard({
    required IconData icon,
    required String titulo,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: cor),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
