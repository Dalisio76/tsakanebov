import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/despesa_form_controller.dart';

class DespesaFormView extends GetView<DespesaFormController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode.value ? 'Editar Despesa' : 'Nova Despesa',
            )),
      ),
      body: Obx(() {
        if (controller.categorias.isEmpty) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descrição
              TextField(
                controller: controller.descricaoController,
                decoration: InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Ex: Ração para gado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 16),

              // Categoria
              DropdownButtonFormField<String>(
                value: controller.categoriaSelecionada.value,
                decoration: InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: controller.categorias.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.nomeComIcone),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.categoriaSelecionada.value = value;
                },
              ),
              SizedBox(height: 16),

              // Valor e Data
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.valorController,
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: controller.selecionarData,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Data *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Obx(() => Text(
                              controller.dataDespesa.value != null
                                  ? DateFormat('dd/MM/yyyy')
                                      .format(controller.dataDespesa.value!)
                                  : 'Selecionar',
                            )),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Quantidade e Unidade (opcional)
              Text(
                'Informações Adicionais (opcional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.quantidadeController,
                      decoration: InputDecoration(
                        labelText: 'Quantidade',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller.unidadeController,
                      decoration: InputDecoration(
                        labelText: 'Unidade',
                        hintText: 'kg, L, un',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Fornecedor
              TextField(
                controller: controller.fornecedorController,
                decoration: InputDecoration(
                  labelText: 'Fornecedor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),

              // Nota Fiscal
              TextField(
                controller: controller.notaFiscalController,
                decoration: InputDecoration(
                  labelText: 'Nota Fiscal',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              SizedBox(height: 24),

              // Vinculação
              Text(
                'Vincular a:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text('Nenhum'),
                        selected: controller.vinculacaoTipo.value == 'nenhum',
                        onSelected: (selected) {
                          if (selected) {
                            controller.vinculacaoTipo.value = 'nenhum';
                            controller.limparVinculacao();
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('Animal'),
                        selected: controller.vinculacaoTipo.value == 'animal',
                        onSelected: (selected) {
                          if (selected) {
                            controller.vinculacaoTipo.value = 'animal';
                            controller.grupoSelecionado.value = null;
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('Grupo'),
                        selected: controller.vinculacaoTipo.value == 'grupo',
                        onSelected: (selected) {
                          if (selected) {
                            controller.vinculacaoTipo.value = 'grupo';
                            controller.animalSelecionado.value = null;
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(height: 16),

              // Dropdown de Animal
              Obx(() => controller.vinculacaoTipo.value == 'animal'
                  ? DropdownButtonFormField<String>(
                      value: controller.animalSelecionado.value,
                      decoration: InputDecoration(
                        labelText: 'Selecione o Animal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pets),
                      ),
                      items: controller.animais.map((animal) {
                        return DropdownMenuItem(
                          value: animal.id,
                          child: Text('${animal.brinco} - ${animal.nome ?? ''}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.animalSelecionado.value = value;
                      },
                    )
                  : SizedBox()),

              // Dropdown de Grupo
              Obx(() => controller.vinculacaoTipo.value == 'grupo'
                  ? DropdownButtonFormField<String>(
                      value: controller.grupoSelecionado.value,
                      decoration: InputDecoration(
                        labelText: 'Selecione o Grupo',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: controller.grupos.map((grupo) {
                        return DropdownMenuItem(
                          value: grupo.id,
                          child: Text(grupo.nome),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller.grupoSelecionado.value = value;
                      },
                    )
                  : SizedBox()),

              SizedBox(height: 32),

              // Botão Salvar
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.salvar,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Despesa',
                              style: TextStyle(fontSize: 16),
                            ),
                    )),
              ),
            ],
          ),
        );
      }),
    );
  }
}
