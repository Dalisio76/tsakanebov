import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestão de Gado 2')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Text('🐄', style: TextStyle(fontSize: 80)),
              SizedBox(height: 20),

              // Título
              Text(
                'Sistema de Gestão de Gado',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),

              // Botão Grupos
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/grupos'),
                  icon: Icon(Icons.folder, size: 28),
                  label: Text(
                    'Gerenciar Grupos',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Animais
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/animais'),
                  icon: Icon(Icons.pets, size: 28),
                  label: Text('Gerenciar Animais', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Pesagem
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/pesagem'),
                  icon: Icon(Icons.monitor_weight, size: 28),
                  label: Text('Registrar Pesagem', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Saúde
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/saude'),
                  icon: Icon(Icons.medical_services, size: 28),
                  label: Text('Registrar Saúde', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Relatório de Saúde
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/relatorio-saude'),
                  icon: Icon(Icons.assignment, size: 24),
                  label: Text('Relatório de Saúde', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Botão Alertas (menor)
              SizedBox(
                width: 250,
                child: OutlinedButton.icon(
                  onPressed: () => Get.toNamed('/alertas-saude'),
                  icon: Icon(Icons.notifications_active, size: 20),
                  label: Text('Ver Alertas', style: TextStyle(fontSize: 14)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.red.shade400, width: 2),
                    foregroundColor: Colors.red.shade400,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Teste Conexão
              SizedBox(
                width: 250,
                child: OutlinedButton.icon(
                  onPressed: controller.irParaTeste,
                  icon: Icon(Icons.wifi, size: 24),
                  label: Text('Testar Conexão', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
