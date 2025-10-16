import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/despesas_controller.dart';

class DespesasView extends GetView<DespesasController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Despesas'),
        actions: [
          IconButton(
            icon: Icon(Icons.assessment),
            onPressed: controller.irParaRelatorio,
            tooltip: 'Relatório',
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
            tooltip: 'Filtros',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        tooltip: 'Nova Despesa',
      ),
      body: Column(
        children: [
          // Busca
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: controller.buscaController,
              decoration: InputDecoration(
                hintText: 'Buscar por descrição...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) => controller.update(),
            ),
          ),

          // Card de Total
          Obx(() => Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade500],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total do Período',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          controller.totalFiltrado,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 48,
                    ),
                  ],
                ),
              )),

          // Lista
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.despesasFiltradas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma despesa encontrada',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregarDespesas,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.despesasFiltradas.length,
                  itemBuilder: (context, index) {
                    final despesa = controller.despesasFiltradas[index];
                    return _buildDespesaCard(despesa);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDespesaCard(despesa) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(despesa),
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
                          despesa.descricao,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (despesa.categoriaNome != null) ...[
                          SizedBox(height: 4),
                          Text(
                            despesa.categoriaNome!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
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
                            Text('Excluir', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') {
                        controller.irParaFormulario(despesa);
                      } else if (value == 'excluir') {
                        controller.deletar(despesa);
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
                        despesa.valorFormatado,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        despesa.dataFormatada,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (despesa.vinculacao != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        despesa.vinculacao!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
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

  void _mostrarFiltros() {
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
              'Filtros',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Text('Período', style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    _buildPeriodoChip('7', '7 dias'),
                    _buildPeriodoChip('30', '30 dias'),
                    _buildPeriodoChip('90', '90 dias'),
                    _buildPeriodoChip('365', '1 ano'),
                  ],
                )),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.limparFiltros();
                      Get.back();
                    },
                    child: Text('Limpar'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    child: Text('Aplicar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoChip(String valor, String label) {
    return Obx(() => ChoiceChip(
          label: Text(label),
          selected: controller.periodoSelecionado.value == valor,
          onSelected: (selected) {
            if (selected) {
              controller.periodoSelecionado.value = valor;
            }
          },
        ));
  }
}
