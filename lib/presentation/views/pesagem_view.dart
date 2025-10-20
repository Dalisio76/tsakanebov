import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pesagem_controller.dart';
import '../widgets/app_drawer.dart';

class PesagemView extends GetView<PesagemController> {
  const PesagemView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Pesagem'),
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
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Digite o brinco e busque o animal',
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
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isBuscandoAnimal.value
                      ? null
                      : controller.buscarAnimal,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
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
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Card do animal selecionado
          Obx(() {
            final animal = controller.animalSelecionado.value;
            if (animal == null) return const SizedBox.shrink();

            return Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (animal.nome != null)
                                Text(
                                  animal.nome!,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (animal.pesoAtualKg != null) ...[
                      const Divider(height: 24),
                      Text(
                        'Peso atual: ${animal.pesoAtualKg!.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if (animal.idadeMeses != null)
                      Text('Idade: ${animal.idadeMeses} meses'),
                    if (animal.grupoNome != null)
                      Text('Grupo: ${animal.grupoNome}'),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Formulário de pesagem
          Obx(() {
            if (controller.animalSelecionado.value == null) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Peso
                TextField(
                  controller: controller.pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Novo Peso (kg) *',
                    hintText: 'Ex: 285.5',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.monitor_weight),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  autofocus: true,
                ),

                const SizedBox(height: 16),

                // Data
                InkWell(
                  onTap: () => controller.selecionarData(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data da Pesagem *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Obx(
                      () => Text(
                        controller.formatarData(controller.dataPesagem.value),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tipo de Pesagem
                Obx(
                  () => DropdownButtonFormField<String>(
                    value: controller.tipoPesagem.value,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Pesagem',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: controller.tiposPesagem.map((String tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo.capitalize!),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.tipoPesagem.value = newValue;
                      }
                    },
                  ),
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
                ),

                const SizedBox(height: 24),

                // Botão Salvar
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.registrarPesagem,
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
                        : const Text('Registrar Pesagem'),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    ),
    );
  }
}
