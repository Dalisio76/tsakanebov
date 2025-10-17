import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/diagnostico_form_controller.dart';

class DiagnosticoFormView extends GetView<DiagnosticoFormController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode.value
                  ? 'Editar Diagnóstico'
                  : 'Novo Diagnóstico',
            )),
      ),
      body: Obx(() {
        if (controller.isLoadingCoberturas.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.coberturas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, size: 64, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Nenhuma cobertura cadastrada',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Cadastre coberturas primeiro',
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
              // Cobertura
              DropdownButtonFormField<String>(
                value: controller.coberturaSelecionada.value,
                decoration: InputDecoration(
                  labelText: 'Cobertura *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                items: controller.coberturas.map((cob) {
                  return DropdownMenuItem(
                    value: cob.id,
                    child: Text(
                        '${cob.femeaBrinco ?? "?"} - ${cob.dataFormatada}'),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.coberturaSelecionada.value = value;
                },
              ),
              SizedBox(height: 16),

              // Data Diagnóstico
              InkWell(
                onTap: controller.selecionarDataDiagnostico,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data do Diagnóstico *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Obx(() => Text(
                        controller.dataDiagnostico.value != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(controller.dataDiagnostico.value!)
                            : 'Selecionar',
                      )),
                ),
              ),
              SizedBox(height: 16),

              // Resultado
              Text(
                'Resultado *',
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
                        label: Text('✅ Prenha'),
                        selected: controller.resultado.value == true,
                        selectedColor: Colors.green.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            controller.resultado.value = true;
                          }
                        },
                      ),
                      ChoiceChip(
                        label: Text('❌ Vazia'),
                        selected: controller.resultado.value == false,
                        selectedColor: Colors.red.shade100,
                        onSelected: (selected) {
                          if (selected) {
                            controller.resultado.value = false;
                            controller.dataPrevistaParto.value = null;
                          }
                        },
                      ),
                    ],
                  )),
              SizedBox(height: 16),

              // Método
              DropdownButtonFormField<String>(
                value: controller.metodoSelecionado.value,
                decoration: InputDecoration(
                  labelText: 'Método',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: [
                  DropdownMenuItem(value: 'palpacao', child: Text('Palpação')),
                  DropdownMenuItem(value: 'ultrassom', child: Text('Ultrassom')),
                ],
                onChanged: (value) {
                  controller.metodoSelecionado.value = value;
                },
              ),
              SizedBox(height: 16),

              // Data Prevista (se prenha)
              Obx(() => controller.resultado.value
                  ? Column(
                      children: [
                        InkWell(
                          onTap: controller.selecionarDataPrevista,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Data Prevista do Parto *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event_available),
                            ),
                            child: Obx(() => Text(
                                  controller.dataPrevistaParto.value != null
                                      ? DateFormat('dd/MM/yyyy').format(
                                          controller.dataPrevistaParto.value!)
                                      : 'Selecionar',
                                )),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    )
                  : SizedBox()),

              // Veterinário
              TextField(
                controller: controller.veterinarioController,
                decoration: InputDecoration(
                  labelText: 'Veterinário',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),

              // Observações
              TextField(
                controller: controller.observacoesController,
                decoration: InputDecoration(
                  labelText: 'Observações',
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
                        backgroundColor: Colors.blue,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Diagnóstico',
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
