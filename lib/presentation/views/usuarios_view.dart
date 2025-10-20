import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/usuarios_controller.dart';
import '../widgets/app_drawer.dart';

class UsuariosView extends GetView<UsuariosController> {
  const UsuariosView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.carregarUsuarios,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final usuarios = controller.usuarios;

        if (usuarios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum usuário encontrado',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregarUsuarios,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: usuario.ativo
                        ? Colors.green.shade100
                        : Colors.grey.shade300,
                    child: Text(
                      usuario.iniciais,
                      style: TextStyle(
                        color: usuario.ativo
                            ? Colors.green.shade800
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    usuario.nomeCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario.email),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(usuario.role),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              usuario.roleNome,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!usuario.ativo)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Inativo',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Get.toNamed('/usuario-edit', arguments: usuario);
                    },
                    tooltip: 'Editar',
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.purple;
      case 'veterinario':
        return Colors.blue;
      case 'funcionario':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
