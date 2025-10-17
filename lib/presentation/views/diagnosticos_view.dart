import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diagnosticos_controller.dart';

class DiagnosticosView extends GetView<DiagnosticosController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnósticos de Prenhez'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: EdgeInsets.all(16),
            child: Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Todos'),
                      selected: controller.filtroResultado.value == 'todos',
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'todos';
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('✅ Prenhas'),
                      selected: controller.filtroResultado.value == 'prenha',
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'prenha';
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('❌ Vazias'),
                      selected: controller.filtroResultado.value == 'vazia',
                      selectedColor: Colors.red.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'vazia';
                        }
                      },
                    ),
                  ],
                )),
          ),

          // Lista
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.diagnosticosFiltrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pregnant_woman, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum diagnóstico encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregarDiagnosticos,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.diagnosticosFiltrados.length,
                  itemBuilder: (context, index) {
                    final diagnostico = controller.diagnosticosFiltrados[index];
                    return _buildDiagnosticoCard(diagnostico);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoCard(diagnostico) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(diagnostico),
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
                          'Fêmea: ${diagnostico.femeaBrinco ?? "Desconhecida"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          diagnostico.dataFormatada,
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
                        controller.irParaFormulario(diagnostico);
                      } else if (value == 'excluir') {
                        controller.deletar(diagnostico);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    diagnostico.resultadoTexto,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: diagnostico.resultado
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  if (diagnostico.resultado &&
                      diagnostico.statusAlerta.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: diagnostico.diasRestantes != null &&
                                diagnostico.diasRestantes! <= 7
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        diagnostico.statusAlerta,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (diagnostico.dataPrevistaParto != null) ...[
                SizedBox(height: 8),
                Text(
                  'Previsão de parto: ${diagnostico.dataPrevistaFormatada}',
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
