import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_drawer.dart';

class PerfilView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Get.defaultDialog(
                title: 'Sair',
                middleText: 'Deseja realmente sair?',
                textConfirm: 'Sim',
                textCancel: 'Não',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: GetBuilder<AuthController>(
        init: Get.find<AuthController>(),
        builder: (controller) {
          final perfil = controller.perfilUsuario.value;

          if (perfil == null) {
            // Tentar carregar o perfil
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.usuarioLogado.value != null) {
                controller.carregarPerfil();
              }
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando perfil...'),
                ],
              ),
            );
          }

          return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade400],
                  ),
                ),
                child: Center(
                  child: Text(
                    perfil.iniciais,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Nome
              Text(
                perfil.nomeCompleto,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Role
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  perfil.roleNome,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Informações
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.green),
                      title: Text('Email'),
                      subtitle: Text(perfil.email),
                    ),
                    Divider(height: 1),
                    if (perfil.telefone != null)
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.green),
                        title: Text('Telefone'),
                        subtitle: Text(perfil.telefone!),
                      ),
                    if (perfil.fazendaNome != null) ...[
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.home, color: Colors.green),
                        title: Text('Fazenda'),
                        subtitle: Text(perfil.fazendaNome!),
                      ),
                    ],
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.shield, color: Colors.green),
                      title: Text('Status'),
                      subtitle: Text(perfil.ativo ? 'Ativo' : 'Inativo'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Botão editar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
        },
      ),
    );
  }
}
