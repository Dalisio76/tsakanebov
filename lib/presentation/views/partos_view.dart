import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/partos_controller.dart';

class PartosView extends GetView<PartosController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.partosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.child_care, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum parto encontrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregarPartos,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.partosFiltrados.length,
            itemBuilder: (context, index) {
              final parto = controller.partosFiltrados[index];
              return _buildPartoCard(parto);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPartoCard(parto) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(parto),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mãe: ${parto.maeBrinco ?? "Desconhecida"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          parto.dataFormatada,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'excluir',
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
                        controller.irParaFormulario(parto);
                      } else if (value == 'excluir') {
                        controller.deletar(parto);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parto.resultadoTexto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: parto.bezerrosVivos > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      if (parto.tipoParto != null) ...[
                        SizedBox(height: 4),
                        Text(
                          parto.tipoPartoFormatado,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (parto.condicaoMae != null)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: parto.condicaoMae == 'boa'
                            ? Colors.green.shade50
                            : parto.condicaoMae == 'regular'
                                ? Colors.orange.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Mãe: ${parto.condicaoMaeFormatada}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (parto.diasGestacao != null) ...[
                SizedBox(height: 8),
                Text(
                  'Gestação: ${parto.diasGestacao} dias',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
