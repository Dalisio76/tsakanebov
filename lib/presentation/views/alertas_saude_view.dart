import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/alertas_saude_controller.dart';

class AlertasSaudeView extends GetView<AlertasSaudeController> {
  const AlertasSaudeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Saúde'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarAlertas,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text(
                  'Mostrar próximos:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Obx(() => SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 7, label: Text('7 dias')),
                        ButtonSegment(value: 15, label: Text('15 dias')),
                        ButtonSegment(value: 30, label: Text('30 dias')),
                      ],
                      selected: {controller.diasFiltro.value},
                      onSelectionChanged: (Set<int> selected) {
                        controller.alterarFiltro(selected.first);
                      },
                    )),
              ],
            ),
          ),

          // Estatísticas
          Obx(() {
            final vencidos = controller.alertasVencidos.length;
            final urgentes = controller.alertasUrgentes.length;
            final proximos = controller.alertasProximos.length;
            final total = controller.alertas.length;

            if (total == 0) {
              return const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 80, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum alerta pendente!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Todos os animais estão em dia',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Card de estatísticas
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard('🔴', 'Vencidos', vencidos,
                              Colors.red),
                          _buildStatCard('🟡', 'Urgentes', urgentes,
                              Colors.orange),
                          _buildStatCard('🟢', 'Próximos', proximos,
                              Colors.green),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Vencidos
                  if (vencidos > 0) ...[
                    Text(
                      '🔴 VENCIDOS ($vencidos)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.alertasVencidos
                        .map((alerta) => _buildAlertaCard(alerta)),
                    const SizedBox(height: 24),
                  ],

                  // Urgentes (7 dias)
                  if (urgentes > 0) ...[
                    Text(
                      '🟡 URGENTES - 7 DIAS ($urgentes)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.alertasUrgentes
                        .map((alerta) => _buildAlertaCard(alerta)),
                    const SizedBox(height: 24),
                  ],

                  // Próximos (8-30 dias)
                  if (proximos > 0) ...[
                    Text(
                      '🟢 PRÓXIMOS - 30 DIAS ($proximos)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...controller.alertasProximos
                        .map((alerta) => _buildAlertaCard(alerta)),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String icon, String label, int value, Color color) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertaCard(registro) {
    Color bgColor;
    switch (registro.statusAlerta) {
      case 'vencido':
        bgColor = Colors.red.shade50;
        break;
      case 'urgente':
        bgColor = Colors.orange.shade50;
        break;
      default:
        bgColor = Colors.green.shade50;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: bgColor,
      child: ListTile(
        leading: Text(
          registro.iconeCategoria,
          style: const TextStyle(fontSize: 32),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                registro.animalBrinco ?? 'Animal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              registro.iconeAlerta,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              registro.tipoEventoNome ?? registro.descricao,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Próxima: ${DateFormat('dd/MM/yyyy').format(registro.proximaAplicacao!)}',
            ),
            if (registro.diasAteProxima != null)
              Text(
                registro.diasAteProxima! >= 0
                    ? 'Faltam ${registro.diasAteProxima} dias'
                    : 'Atrasado ${registro.diasAteProxima!.abs()} dias',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: registro.diasAteProxima! >= 0
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navegar para detalhes do animal
          Get.toNamed('/historico-saude',
              arguments: registro.animalBrinco);
        },
      ),
    );
  }
}
