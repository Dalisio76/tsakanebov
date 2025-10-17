import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/cobertura_form_controller.dart';

class CoberturaFormView extends GetView<CoberturaFormController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode.value
                  ? 'Editar Cobertura'
                  : 'Nova Cobertura',
            )),
      ),
      body: Obx(() {
        if (controller.isLoadingAnimais.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.femeas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Nenhuma fêmea cadastrada',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Cadastre animais fêmeas primeiro',
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Voltar'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fêmea
              DropdownButtonFormField<String>(
                value: controller.femeaSelecionada.value,
                decoration: InputDecoration(
                  labelText: 'Fêmea *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets),
                ),
                items: controller.femeas.map((femea) {
                  return DropdownMenuItem(
                    value: femea.id,
                    child: Text('${femea.brinco} - ${femea.nome ?? ''}'),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.femeaSelecionada.value = value;
                },
              ),
              SizedBox(height: 16),

              // Tipo de Cobertura
              Text(
                'Tipo de Cobertura *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 12),
              Obx(() => Wrap(
                    spacing: 12,
                    children: [
                      ChoiceChip(
                        label: Text('🐂 Monta Natural'),
                        selected: controller.tipoSelecionado.value == 'monta_natural',
                        onSelected: (selected) {
                          if (selected) {
                            controller.tipoSelecionado.value = 'monta_natural';
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('💉 Inseminação'),
                        selected: controller.tipoSelecionado.value == 'inseminacao',
                        onSelected: (selected) {
                          if (selected) {
                            controller.tipoSelecionado.value = 'inseminacao';
                            controller.machoSelecionado.value = null;
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(height: 16),

              // Macho (Monta Natural)
              Obx(() => controller.tipoSelecionado.value == 'monta_natural'
                  ? Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: controller.machoSelecionado.value,
                          decoration: InputDecoration(
                            labelText: 'Macho *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.male),
                          ),
                          items: controller.machos.map((macho) {
                            return DropdownMenuItem(
                              value: macho.id,
                              child: Text('${macho.brinco} - ${macho.nome ?? ''}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            controller.machoSelecionado.value = value;
                          },
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  : SizedBox()),

              // Touro/Sêmen (Inseminação)
              Obx(() => controller.tipoSelecionado.value == 'inseminacao'
                  ? Column(
                      children: [
                        TextField(
                          controller: controller.touroSemenController,
                          decoration: InputDecoration(
                            labelText: 'Touro/Sêmen *',
                            hintText: 'Ex: Touro XYZ',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.science),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: controller.racaTouroController,
                          decoration: InputDecoration(
                            labelText: 'Raça do Touro',
                            hintText: 'Ex: Nelore, Angus',
                            border: OutlineInputBorder(),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  : SizedBox()),

              // Data
              InkWell(
                onTap: controller.selecionarData,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data da Cobertura *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Obx(() => Text(
                        controller.dataCobertura.value != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(controller.dataCobertura.value!)
                            : 'Selecionar',
                      )),
                ),
              ),
              SizedBox(height: 16),

              // Observações
              TextField(
                controller: controller.observacoesController,
                decoration: InputDecoration(
                  labelText: 'Observações',
                  hintText: 'Informações adicionais...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
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
                        backgroundColor: Colors.pink,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Cobertura',
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
