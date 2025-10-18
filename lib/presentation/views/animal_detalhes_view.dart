import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/animal_model.dart';

class AnimalDetalhesView extends StatelessWidget {
  const AnimalDetalhesView({super.key});

  @override
  Widget build(BuildContext context) {
    final AnimalModel animal = Get.arguments as AnimalModel;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header com imagem ou ícone
            Container(
              height: 200,
              color: animal.sexo == 'M'
                  ? Colors.blue.shade100
                  : Colors.pink.shade100,
              child: animal.urlImagem != null && animal.urlImagem!.isNotEmpty
                  ? Image.network(
                      animal.urlImagem!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.pets, size: 80, color: Colors.grey),
                      ),
                    )
                  : Center(
                      child: Text(
                        animal.sexo == 'M' ? '♂️' : '♀️',
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
            ),

            // Informações principais
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brinco e Nome
                  Row(
                    children: [
                      Text(
                        animal.brinco,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (animal.nome != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            animal.nome!,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Status
                  Chip(
                    label: Text(animal.status.toUpperCase()),
                    backgroundColor: animal.status == 'ativo'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),

                  const SizedBox(height: 24),

                  // Cards de informação
                  _buildInfoCard('Informações Básicas', [
                    _buildInfoRow(
                        'Sexo', animal.sexo == 'M' ? 'Macho ♂️' : 'Fêmea ♀️'),
                    _buildInfoRow('Data de Nascimento',
                        DateFormat('dd/MM/yyyy').format(animal.dataNascimento)),
                    if (animal.idadeMeses != null)
                      _buildInfoRow('Idade', '${animal.idadeMeses} meses'),
                    if (animal.raca != null) _buildInfoRow('Raça', animal.raca!),
                    if (animal.tipoPele != null)
                      _buildInfoRow('Tipo de Pele', animal.tipoPele!),
                  ]),

                  const SizedBox(height: 16),

                  // Peso
                  if (animal.pesoAtualKg != null)
                    _buildInfoCard('Peso', [
                      _buildInfoRow('Peso Atual',
                          '${animal.pesoAtualKg!.toStringAsFixed(1)} kg'),
                      if (animal.dataUltimaPesagem != null)
                        _buildInfoRow(
                            'Última Pesagem',
                            DateFormat('dd/MM/yyyy')
                                .format(animal.dataUltimaPesagem!)),
                    ]),

                  const SizedBox(height: 16),

                  // Grupo
                  if (animal.grupoNome != null)
                    _buildInfoCard('Grupo', [
                      _buildInfoRow('Grupo', animal.grupoNome!),
                    ]),

                  const SizedBox(height: 16),

                  // Genealogia
                  if (animal.paiBrinco != null || animal.maeBrinco != null)
                    _buildInfoCard('Genealogia', [
                      if (animal.paiBrinco != null)
                        _buildInfoRow('Pai', animal.paiBrinco!),
                      if (animal.maeBrinco != null)
                        _buildInfoRow('Mãe', animal.maeBrinco!),
                    ]),

                  const SizedBox(height: 16),

                  // Observações
                  if (animal.observacoes != null &&
                      animal.observacoes!.isNotEmpty)
                    _buildInfoCard('Observações', [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          animal.observacoes!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ]),

                  const SizedBox(height: 24),

                  // Botão Ver Histórico de Pesagens
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/historico-pesagem', arguments: animal);
                    },
                    icon: const Icon(Icons.timeline),
                    label: const Text('Ver Histórico de Pesagens'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Registrar Nova Pesagem
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.toNamed('/pesagem');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Nova Pesagem'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Ver Histórico de Saúde
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.toNamed('/historico-saude', arguments: animal);
                    },
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Ver Histórico de Saúde'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.red.shade400,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botão Registrar Evento de Saúde
                  OutlinedButton.icon(
                    onPressed: () {
                      Get.toNamed('/saude');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar Evento de Saúde'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.red.shade400),
                      foregroundColor: Colors.red.shade400,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Datas de registro
                  _buildInfoCard('Sistema', [
                    if (animal.criadoEm != null)
                      _buildInfoRow('Cadastrado em',
                          DateFormat('dd/MM/yyyy HH:mm').format(animal.criadoEm!)),
                    if (animal.atualizadoEm != null)
                      _buildInfoRow(
                          'Última atualização',
                          DateFormat('dd/MM/yyyy HH:mm')
                              .format(animal.atualizadoEm!)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String titulo, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
