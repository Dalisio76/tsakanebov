import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/parto_form_controller.dart';

class PartoFormView extends GetView<PartoFormController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.isEditMode.value ? 'Editar Parto' : 'Novo Parto',
            )),
      ),
      body: Obx(() {
        if (controller.isLoadingDados.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cobertura (opcional)
              DropdownButtonFormField<String>(
                value: controller.coberturaSelecionada.value,
                decoration: InputDecoration(
                  labelText: 'Cobertura (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                  helperText: 'Vincular a uma cobertura existente',
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text('Nenhuma')),
                  ...controller.coberturas.map((cob) {
                    return DropdownMenuItem(
                      value: cob.id,
                      child: Text(
                          '${cob.femeaBrinco ?? "?"} - ${cob.dataFormatada}'),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  controller.coberturaSelecionada.value = value;
                },
              ),
              SizedBox(height: 16),

              // Data do Parto
              InkWell(
                onTap: controller.selecionarData,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data do Parto *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Obx(() => Text(
                        controller.dataParto.value != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(controller.dataParto.value!)
                            : 'Selecionar',
                      )),
                ),
              ),
              SizedBox(height: 16),

              // Bezerros
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.bezerrosVivosController,
                      decoration: InputDecoration(
                        labelText: 'Bezerros Vivos *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.check_circle, color: Colors.green),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller.bezerrosMortosController,
                      decoration: InputDecoration(
                        labelText: 'Bezerros Mortos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cancel, color: Colors.red),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Tipo de Parto
              DropdownButtonFormField<String>(
                value: controller.tipoPartoSelecionado.value,
                decoration: InputDecoration(
                  labelText: 'Tipo de Parto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: [
                  DropdownMenuItem(value: 'normal', child: Text('✅ Normal')),
                  DropdownMenuItem(
                      value: 'assistido', child: Text('🤝 Assistido')),
                  DropdownMenuItem(
                      value: 'cesariana', child: Text('🔪 Cesariana')),
                ],
                onChanged: (value) {
                  controller.tipoPartoSelecionado.value = value;
                },
              ),
              SizedBox(height: 16),

              // Condição da Mãe
              DropdownButtonFormField<String>(
                value: controller.condicaoMaeSelecionada.value,
                decoration: InputDecoration(
                  labelText: 'Condição da Mãe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.health_and_safety),
                ),
                items: [
                  DropdownMenuItem(value: 'boa', child: Text('🟢 Boa')),
                  DropdownMenuItem(value: 'regular', child: Text('🟡 Regular')),
                  DropdownMenuItem(value: 'ruim', child: Text('🔴 Ruim')),
                ],
                onChanged: (value) {
                  controller.condicaoMaeSelecionada.value = value;
                },
              ),
              SizedBox(height: 16),

              // Complicações
              TextField(
                controller: controller.complicacoesController,
                decoration: InputDecoration(
                  labelText: 'Complicações',
                  hintText: 'Descreva se houve complicações...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.warning_amber),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              SizedBox(height: 16),

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
                        backgroundColor: Colors.green,
                      ),
                      child: controller.isLoading.value
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Salvar Parto',
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
