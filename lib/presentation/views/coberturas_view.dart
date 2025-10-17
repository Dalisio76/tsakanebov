import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/coberturas_controller.dart';

class CoberturasView extends GetView<CoberturasController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coberturas'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'diagnosticos',
                child: Row(
                  children: [
                    Icon(Icons.pregnant_woman, size: 20),
                    SizedBox(width: 8),
                    Text('Diagnósticos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'partos',
                child: Row(
                  children: [
                    Icon(Icons.child_care, size: 20),
                    SizedBox(width: 8),
                    Text('Partos'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'relatorio',
                child: Row(
                  children: [
                    Icon(Icons.assessment, size: 20),
                    SizedBox(width: 8),
                    Text('Relatório'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'diagnosticos') {
                controller.irParaDiagnosticos();
              } else if (value == 'partos') {
                controller.irParaPartos();
              } else if (value == 'relatorio') {
                controller.irParaRelatorio();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Busca
                TextField(
                  controller: controller.buscaController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por fêmea',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        controller.buscaController.clear();
                        controller.update();
                      },
                    ),
                  ),
                  onChanged: (value) => controller.update(),
                ),
                SizedBox(height: 12),
                // Filtro de tipo
                Obx(() => Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('Todos'),
                          selected: controller.tipoFiltro.value == 'todos',
                          onSelected: (selected) {
                            if (selected) {
                              controller.tipoFiltro.value = 'todos';
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('🐂 Monta Natural'),
                          selected:
                              controller.tipoFiltro.value == 'monta_natural',
                          onSelected: (selected) {
                            if (selected) {
                              controller.tipoFiltro.value = 'monta_natural';
                            }
                          },
                        ),
                        ChoiceChip(
                          label: Text('💉 Inseminação'),
                          selected:
                              controller.tipoFiltro.value == 'inseminacao',
                          onSelected: (selected) {
                            if (selected) {
                              controller.tipoFiltro.value = 'inseminacao';
                            }
                          },
                        ),
                      ],
                    )),
              ],
            ),
          ),

          // Lista
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.coberturasFiltradas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma cobertura encontrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregarCoberturas,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.coberturasFiltradas.length,
                  itemBuilder: (context, index) {
                    final cobertura = controller.coberturasFiltradas[index];
                    return _buildCoberturaCard(cobertura);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCoberturaCard(cobertura) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(cobertura),
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
                          'Fêmea: ${cobertura.femeaBrinco ?? "Desconhecida"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          cobertura.dataFormatada,
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
                        controller.irParaFormulario(cobertura);
                      } else if (value == 'excluir') {
                        controller.deletar(cobertura);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: cobertura.tipo == 'monta_natural'
                          ? Colors.brown.shade50
                          : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cobertura.tipoFormatado,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      cobertura.reproducaoInfo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
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
}
