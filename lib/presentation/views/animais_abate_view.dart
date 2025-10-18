import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/services/animal_service.dart';
import '../widgets/app_drawer.dart';

class AnimaisAbateView extends StatefulWidget {
  const AnimaisAbateView({super.key});

  @override
  State<AnimaisAbateView> createState() => _AnimaisAbateViewState();
}

class _AnimaisAbateViewState extends State<AnimaisAbateView> {
  final AnimalService _animalService = AnimalService();
  var animaisAbate = <AnimalModel>[].obs;
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    carregarAnimaisAbate();
  }

  Future<void> carregarAnimaisAbate() async {
    try {
      isLoading.value = true;
      // Carregar animais com status 'abate'
      animaisAbate.value = await _animalService.listarAnimais(apenasAtivos: false);
      // Filtrar apenas os para abate e ordenar por peso (mais pesados primeiro)
      animaisAbate.value = animaisAbate
          .where((a) => a.status == 'abate')
          .toList()
        ..sort((a, b) => (b.pesoAtualKg ?? 0).compareTo(a.pesoAtualKg ?? 0));
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar animais para abate: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void irParaDetalhes(AnimalModel animal) {
    Get.toNamed('/animais/detalhes', arguments: animal);
  }

  double calcularArrobas(double? pesoKg) {
    if (pesoKg == null) return 0;
    return pesoKg / 15;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🥩 Animais para Abate'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarAnimaisAbate,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (animaisAbate.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum animal marcado para abate',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Marque animais como "Abate" no formulário',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Estatísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.brown.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total',
                    animaisAbate.length.toString(),
                    Icons.format_list_numbered,
                    Colors.brown,
                  ),
                  _buildStatCard(
                    'Peso Total',
                    '${animaisAbate.fold<double>(0, (sum, a) => sum + (a.pesoAtualKg ?? 0)).toStringAsFixed(0)} kg',
                    Icons.monitor_weight,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    'Arrobas',
                    calcularArrobas(
                      animaisAbate.fold<double>(0, (sum, a) => sum + (a.pesoAtualKg ?? 0)),
                    ).toStringAsFixed(1),
                    Icons.scale,
                    Colors.green,
                  ),
                ],
              ),
            ),

            // Lista
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: animaisAbate.length,
                itemBuilder: (context, index) {
                  final animal = animaisAbate[index];
                  final arrobas = calcularArrobas(animal.pesoAtualKg);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown.shade700,
                        child: Text(
                          animal.sexo == 'M' ? '♂️' : '♀️',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      title: Text(
                        'Brinco: ${animal.brinco}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          if (animal.nome != null)
                            Text(
                              'Nome: ${animal.nome}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          Row(
                            children: [
                              Text(
                                'Peso: ${animal.pesoAtualKg?.toStringAsFixed(0) ?? 0} kg',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '(${arrobas.toStringAsFixed(1)} @)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (animal.idadeMeses != null)
                            Text(
                              'Idade: ${animal.idadeMeses} meses',
                              style: const TextStyle(fontSize: 13),
                            ),
                          if (animal.grupoNome != null)
                            Text(
                              'Grupo: ${animal.grupoNome}',
                              style: const TextStyle(fontSize: 13),
                            ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.brown.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'ABATE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                      onTap: () => irParaDetalhes(animal),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
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
}
