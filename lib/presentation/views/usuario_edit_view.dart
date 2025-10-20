import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/usuarios_controller.dart';

class UsuarioEditView extends GetView<UsuariosController> {
  const UsuarioEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Usuário'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar e Nome
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final usuario = controller.usuarioEditando.value;
                    if (usuario == null) return const SizedBox.shrink();

                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade100,
                      ),
                      child: Center(
                        child: Text(
                          usuario.iniciais,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Obx(() {
                    final usuario = controller.usuarioEditando.value;
                    if (usuario == null) return const SizedBox.shrink();

                    return Text(
                      usuario.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Nome Completo
            TextField(
              controller: controller.nomeCompletoController,
              decoration: const InputDecoration(
                labelText: 'Nome Completo *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Telefone
            TextField(
              controller: controller.telefoneController,
              decoration: const InputDecoration(
                labelText: 'Telefone',
                hintText: '(00) 00000-0000',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Role (Função)
            Obx(() => DropdownButtonFormField<String>(
              value: controller.roleEditando.value,
              decoration: const InputDecoration(
                labelText: 'Função *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.badge),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'admin',
                  child: Text('Administrador'),
                ),
                DropdownMenuItem(
                  value: 'veterinario',
                  child: Text('Veterinário'),
                ),
                DropdownMenuItem(
                  value: 'funcionario',
                  child: Text('Funcionário'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.roleEditando.value = newValue;
                }
              },
            )),
            const SizedBox(height: 16),

            // Status Ativo/Inativo
            Obx(() => SwitchListTile(
              title: const Text('Usuário Ativo'),
              subtitle: Text(
                controller.ativoEditando.value
                    ? 'O usuário pode acessar o sistema'
                    : 'O usuário não pode acessar o sistema',
              ),
              value: controller.ativoEditando.value,
              onChanged: (bool value) {
                controller.ativoEditando.value = value;
              },
              secondary: Icon(
                controller.ativoEditando.value
                    ? Icons.check_circle
                    : Icons.cancel,
                color: controller.ativoEditando.value
                    ? Colors.green
                    : Colors.red,
              ),
            )),
            const SizedBox(height: 24),

            // Botão Salvar
            Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.salvarEdicao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: controller.isLoading.value
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('Salvando...'),
                      ],
                    )
                  : const Text('Salvar Alterações'),
            )),
          ],
        ),
      ),
    );
  }
}
