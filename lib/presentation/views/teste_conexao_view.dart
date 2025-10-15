import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teste_controller.dart';

class TesteConexaoView extends GetView<TesteController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Teste de Conexão')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Teste Supabase',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),

              Obx(
                () => controller.isLoading.value
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: controller.testarConexao,
                        child: Text('Testar Conexão'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                        ),
                      ),
              ),

              SizedBox(height: 20),

              Obx(
                () => controller.errorMessage.value.isNotEmpty
                    ? Text(
                        'Erro: ${controller.errorMessage.value}',
                        style: TextStyle(color: Colors.red),
                      )
                    : SizedBox(),
              ),

              SizedBox(height: 20),

              Obx(
                () => Expanded(
                  child: ListView.builder(
                    itemCount: controller.grupos.length,
                    itemBuilder: (context, index) {
                      final grupo = controller.grupos[index];
                      return Card(
                        child: ListTile(
                          title: Text(grupo['nome'] ?? 'Sem nome'),
                          subtitle: Text(grupo['finalidade'] ?? ''),
                        ),
                      );
                    },
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
