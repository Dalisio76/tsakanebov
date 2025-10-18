import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/services/animal_service.dart';
import '../widgets/app_drawer.dart';

class AnimaisMortosView extends StatefulWidget {
  const AnimaisMortosView({super.key});

  @override
  State<AnimaisMortosView> createState() => _AnimaisMortosViewState();
}

class _AnimaisMortosViewState extends State<AnimaisMortosView> {
  final AnimalService _animalService = AnimalService();
  var animaisMortos = <AnimalModel>[].obs;
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    carregarAnimaisMortos();
  }

  Future<void> carregarAnimaisMortos() async {
    try {
      isLoading.value = true;
      // Carregar animais com status 'morto'
      animaisMortos.value = await _animalService.listarAnimais(apenasAtivos: false);
      // Filtrar apenas os mortos
      animaisMortos.value = animaisMortos.where((a) => a.status == 'morto').toList();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar animais mortos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void irParaDetalhes(AnimalModel animal) {
    Get.toNamed('/animais/detalhes', arguments: animal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💀 Animais Mortos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: carregarAnimaisMortos,
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (animaisMortos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Nenhum animal morto registrado'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: animaisMortos.length,
          itemBuilder: (context, index) {
            final animal = animaisMortos[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade800,
                  child: Text(
                    animal.sexo == 'M' ? '♂️' : '♀️',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                title: Text(
                  'Brinco: ${animal.brinco}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (animal.nome != null) Text('Nome: ${animal.nome}'),
                    Text('Idade: ${animal.idadeMeses ?? 0} meses'),
                    if (animal.observacoes != null)
                      Text(
                        'Obs: ${animal.observacoes}',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => irParaDetalhes(animal),
              ),
            );
          },
        );
      }),
    );
  }
}
