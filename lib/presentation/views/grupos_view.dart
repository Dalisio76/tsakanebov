import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/grupos_controller.dart';

class GruposView extends GetView<GruposController> {
  const GruposView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarGrupos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar grupo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: controller.buscarPorNome,
            ),
          ),

          // Lista de grupos
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.grupos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhum grupo encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: controller.irParaCriar,
                        icon: const Icon(Icons.add),
                        label: const Text('Criar Primeiro Grupo'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.grupos.length,
                itemBuilder: (context, index) {
                  final grupo = controller.grupos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(grupo.nome[0].toUpperCase()),
                      ),
                      title: Text(
                        grupo.nome,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (grupo.finalidade != null)
                            Text('Finalidade: ${grupo.finalidade}'),
                          if (grupo.descricao != null)
                            Text(grupo.descricao!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Editar'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'deletar',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'editar') {
                            controller.irParaEditar(grupo);
                          } else if (value == 'deletar') {
                            controller.deletarGrupo(grupo);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.irParaCriar,
        tooltip: 'Novo Grupo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
