import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/grupo_form_controller.dart';

class GrupoFormView extends GetView<GrupoFormController> {
  const GrupoFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Editar Grupo' : 'Novo Grupo')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nome
            TextField(
              controller: controller.nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo *',
                hintText: 'Ex: Recria 2024',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Finalidade (Dropdown)
            DropdownButtonFormField<String>(
              value: controller.finalidadeController.text.isEmpty
                  ? null
                  : controller.finalidadeController.text,
              decoration: const InputDecoration(
                labelText: 'Finalidade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: controller.finalidades.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.finalidadeController.text = newValue;
                }
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextField(
              controller: controller.descricaoController,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Informações adicionais sobre o grupo',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Botão Salvar
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Salvando...'),
                          ],
                        )
                      : const Text('Salvar'),
                )),
          ],
        ),
      ),
    );
  }
}
