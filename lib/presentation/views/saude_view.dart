import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/saude_controller.dart';
import '../widgets/app_drawer.dart';

class SaudeView extends GetView<SaudeController> {
  const SaudeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Evento de Saúde'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de instrução
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Registre vacinas, medicamentos e procedimentos',
                        style: TextStyle(color: Colors.blue.shade900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Buscar animal
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.brincoController,
                    decoration: const InputDecoration(
                      labelText: 'Brinco do Animal',
                      hintText: 'Ex: 001',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => controller.buscarAnimal(),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton(
                      onPressed: controller.isBuscandoAnimal.value
                          ? null
                          : controller.buscarAnimal,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 20),
                      ),
                      child: controller.isBuscandoAnimal.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Buscar'),
                    )),
              ],
            ),

            const SizedBox(height: 24),

            // Card do animal
            Obx(() {
              final animal = controller.animalSelecionado.value;
              if (animal == null) return const SizedBox.shrink();

              return Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: animal.sexo == 'M'
                            ? Colors.blue
                            : Colors.pink,
                        child: Text(
                          animal.sexo == 'M' ? '♂️' : '♀️',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              animal.brinco,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (animal.nome != null) Text(animal.nome!),
                            if (animal.grupoNome != null)
                              Text('Grupo: ${animal.grupoNome}',
                                  style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 24),

            // Formulário
            Obx(() {
              if (controller.animalSelecionado.value == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tipo de Evento
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.tipoSelecionado.value,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Evento *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        items: controller.tiposEvento.map((tipo) {
                          return DropdownMenuItem<String>(
                            value: tipo.id,
                            child: Row(
                              children: [
                                Text(tipo.icone,
                                    style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(tipo.nome),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          controller.tipoSelecionado.value = value;
                        },
                      )),

                  const SizedBox(height: 16),

                  // Descrição
                  TextField(
                    controller: controller.descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição *',
                      hintText: 'Ex: Aplicação da 1ª dose',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 16),

                  // Data do Evento
                  InkWell(
                    onTap: () => controller.selecionarDataEvento(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data do Evento *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Obx(() => Text(
                            controller
                                .formatarData(controller.dataEvento.value),
                            style: const TextStyle(fontSize: 16),
                          )),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Veterinário
                  TextField(
                    controller: controller.veterinarioController,
                    decoration: const InputDecoration(
                      labelText: 'Veterinário',
                      hintText: 'Nome do profissional',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),

                  const SizedBox(height: 16),

                  // Custo
                  TextField(
                    controller: controller.custoController,
                    decoration: const InputDecoration(
                      labelText: 'Custo (R\$)',
                      hintText: 'Ex: 45.00',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),

                  const SizedBox(height: 24),

                  // Próxima aplicação
                  Obx(() => CheckboxListTile(
                        title: const Text('Agendar próxima aplicação'),
                        subtitle: const Text('Para vacinas que precisam de reforço'),
                        value: controller.temProximaDose.value,
                        onChanged: (value) {
                          controller.temProximaDose.value = value ?? false;
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                      )),

                  Obx(() {
                    if (!controller.temProximaDose.value) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      children: [
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () =>
                              controller.selecionarProximaAplicacao(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Próxima Aplicação',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.event),
                            ),
                            child: Text(
                              controller.formatarData(
                                  controller.proximaAplicacao.value),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),

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

                  // Botão Salvar
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.registrarEvento,
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
                                  Text('Registrando...'),
                                ],
                              )
                            : const Text('Registrar Evento'),
                      )),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
