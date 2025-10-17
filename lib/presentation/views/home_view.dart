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

              // Botão Dashboard
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/dashboard'),
                  icon: Icon(Icons.dashboard, size: 28),
                  label: Text('Dashboard', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.teal,
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

              // Botão Despesas
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/despesas'),
                  icon: Icon(Icons.attach_money, size: 28),
                  label: Text('Gerenciar Despesas', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Botão Reprodução
              SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/coberturas'),
                  icon: Icon(Icons.pregnant_woman, size: 28),
                  label: Text('Reprodução', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Botões Secundários
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Botão Alertas
                  OutlinedButton.icon(
                    onPressed: () => Get.toNamed('/alertas-saude'),
                    icon: Icon(Icons.notifications, size: 20),
                    label: Text('Alertas'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Botão Relatórios
                  OutlinedButton.icon(
                    onPressed: _mostrarRelatorios,
                    icon: Icon(Icons.assessment, size: 20),
                    label: Text('Relatórios'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(width: 12),

                  // Botão Teste
                  OutlinedButton.icon(
                    onPressed: controller.irParaTeste,
                    icon: Icon(Icons.wifi, size: 20),
                    label: Text('Teste'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _mostrarRelatorios() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relatórios',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.attach_money, color: Colors.purple),
              title: Text('Relatório de Custos'),
              onTap: () {
                Get.back();
                Get.toNamed('/relatorio-custos');
              },
            ),
            ListTile(
              leading: Icon(Icons.pregnant_woman, color: Colors.pink),
              title: Text('Relatório de Reprodução'),
              onTap: () {
                Get.back();
                Get.toNamed('/relatorio-reproducao');
              },
            ),
            ListTile(
              leading: Icon(Icons.medical_services, color: Colors.red),
              title: Text('Relatório de Saúde'),
              onTap: () {
                Get.back();
                Get.toNamed('/relatorio-saude');
              },
            ),
          ],
        ),
      ),
    );
  }
}
