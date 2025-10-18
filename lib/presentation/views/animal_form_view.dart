import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/animal_form_controller.dart';

class AnimalFormView extends GetView<AnimalFormController> {
  const AnimalFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
            controller.isEditMode.value ? 'Editar Animal' : 'Novo Animal')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brinco (obrigatório)
            TextField(
              controller: controller.brincoController,
              decoration: const InputDecoration(
                labelText: 'Brinco *',
                hintText: 'Ex: 001',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),

            // Nome (opcional)
            TextField(
              controller: controller.nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome (opcional)',
                hintText: 'Ex: Mimosa',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pets),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Sexo
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.sexoSelecionado.value,
                  decoration: const InputDecoration(
                    labelText: 'Sexo *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc),
                  ),
                  items: controller.sexos.map((String sexo) {
                    return DropdownMenuItem<String>(
                      value: sexo,
                      child: Text(sexo == 'M' ? '♂️ Macho' : '♀️ Fêmea'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.sexoSelecionado.value = newValue;
                    }
                  },
                )),
            const SizedBox(height: 16),

            // Status
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.statusSelecionado.value,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                  ),
                  items: controller.statusOptions.map((String status) {
                    IconData icon;
                    String label;
                    switch (status) {
                      case 'ativo':
                        icon = Icons.check_circle;
                        label = 'Ativo';
                        break;
                      case 'vendido':
                        icon = Icons.sell;
                        label = 'Vendido';
                        break;
                      case 'morto':
                        icon = Icons.heart_broken;
                        label = 'Morto';
                        break;
                      case 'transferido':
                        icon = Icons.compare_arrows;
                        label = 'Transferido';
                        break;
                      case 'abate':
                        icon = Icons.restaurant;
                        label = 'Abate';
                        break;
                      default:
                        icon = Icons.help;
                        label = status;
                    }
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Row(
                        children: [
                          Icon(icon, size: 20),
                          const SizedBox(width: 8),
                          Text(label),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.statusSelecionado.value = newValue;
                    }
                  },
                )),
            const SizedBox(height: 16),

            // Data de Nascimento
            InkWell(
              onTap: () => controller.selecionarData(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Obx(() => Text(
                      controller.formatarData(controller.dataNascimento.value),
                      style: const TextStyle(fontSize: 16),
                    )),
              ),
            ),
            const SizedBox(height: 16),

            // Grupo
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.grupoSelecionado.value,
                  decoration: const InputDecoration(
                    labelText: 'Grupo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.folder),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sem grupo')),
                    ...controller.grupos.map((grupo) => DropdownMenuItem(
                          value: grupo.id,
                          child: Text(grupo.nome),
                        )),
                  ],
                  onChanged: (value) {
                    controller.grupoSelecionado.value = value;
                  },
                )),
            const SizedBox(height: 16),

            // Raça
            DropdownButtonFormField<String>(
              value: controller.racaController.text.isEmpty
                  ? null
                  : controller.racaController.text,
              decoration: const InputDecoration(
                labelText: 'Raça',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: controller.racas.map((String raca) {
                return DropdownMenuItem<String>(
                  value: raca,
                  child: Text(raca),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.racaController.text = newValue;
                }
              },
            ),
            const SizedBox(height: 16),

            // Tipo de Pele
            TextField(
              controller: controller.tipoPeleController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Pele',
                hintText: 'Ex: Manchada, Preta, Branca',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Peso Inicial
            TextField(
              controller: controller.pesoController,
              decoration: const InputDecoration(
                labelText: 'Peso Inicial (kg)',
                hintText: 'Ex: 45.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 24),

            // Seção Genealogia
            const Text(
              'Genealogia (opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Pai
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.paiSelecionado.value,
                  decoration: const InputDecoration(
                    labelText: 'Pai',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.male),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Desconhecido')),
                    ...controller.possiveisPais.map((animal) =>
                        DropdownMenuItem(
                          value: animal.id,
                          child: Text(
                              '${animal.brinco}${animal.nome != null ? " (${animal.nome})" : ""}'),
                        )),
                  ],
                  onChanged: (value) {
                    controller.paiSelecionado.value = value;
                  },
                )),
            const SizedBox(height: 16),

            // Mãe
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.maeSelecionada.value,
                  decoration: const InputDecoration(
                    labelText: 'Mãe',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.female),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Desconhecida')),
                    ...controller.possiveisMaes.map((animal) =>
                        DropdownMenuItem(
                          value: animal.id,
                          child: Text(
                              '${animal.brinco}${animal.nome != null ? " (${animal.nome})" : ""}'),
                        )),
                  ],
                  onChanged: (value) {
                    controller.maeSelecionada.value = value;
                  },
                )),
            const SizedBox(height: 24),

            // Foto do Animal
            const Text(
              'Foto do Animal',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Preview da imagem
            Obx(() {
              if (controller.isUploadingImage.value) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Enviando foto...'),
                      ],
                    ),
                  ),
                );
              }

              if (controller.imagemSelecionada.value != null) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green, width: 2),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          controller.imagemSelecionada.value!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: controller.removerImagem,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.urlImagemController.text.isNotEmpty) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          controller.urlImagemController.text,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.error, size: 48, color: Colors.red),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: controller.removerImagem,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      Text(
                        'Nenhuma foto selecionada',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Botões de upload
            Row(
              children: [
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isUploadingImage.value
                        ? null
                        : controller.selecionarEUploadFoto,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeria'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  )),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isUploadingImage.value
                        ? null
                        : controller.tirarFoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Câmera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                    ),
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Observações
            TextField(
              controller: controller.observacoesController,
              decoration: const InputDecoration(
                labelText: 'Observações',
                hintText: 'Informações adicionais',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Checkbox "Criar outro" (só no modo criar)
            Obx(() {
              if (controller.isEditMode.value) return const SizedBox.shrink();

              return CheckboxListTile(
                title: const Text('Criar outro animal após salvar'),
                subtitle:
                    const Text('Limpa os campos para cadastrar o próximo animal'),
                value: controller.criarOutro.value,
                onChanged: (bool? value) {
                  controller.criarOutro.value = value ?? false;
                },
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            const SizedBox(height: 16),

            // Botão Salvar
            Obx(() => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.salvar,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
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
                            SizedBox(width: 12),
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
