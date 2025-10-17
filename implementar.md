# 🤰 MÓDULO REPRODUÇÃO - VIEWS FINAIS
## Arquivos 9-14 (Views Restantes)

---

## 📦 ARQUIVO 9/14: cobertura_form_view.dart

**Caminho:** `lib/presentation/views/cobertura_form_view.dart`

```dart
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
        if (controller.femeas.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
```

---

## 📦 ARQUIVO 10/14: diagnosticos_view.dart

**Caminho:** `lib/presentation/views/diagnosticos_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/diagnosticos_controller.dart';

class DiagnosticosView extends GetView<DiagnosticosController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnósticos de Prenhez'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: EdgeInsets.all(16),
            child: Obx(() => Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Todos'),
                      selected: controller.filtroResultado.value == 'todos',
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'todos';
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('✅ Prenhas'),
                      selected: controller.filtroResultado.value == 'prenha',
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'prenha';
                        }
                      },
                    ),
                    ChoiceChip(
                      label: Text('❌ Vazias'),
                      selected: controller.filtroResultado.value == 'vazia',
                      selectedColor: Colors.red.shade100,
                      onSelected: (selected) {
                        if (selected) {
                          controller.filtroResultado.value = 'vazia';
                        }
                      },
                    ),
                  ],
                )),
          ),

          // Lista
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.diagnosticosFiltrados.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.pregnant_woman, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum diagnóstico encontrado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.carregarDiagnosticos,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: controller.diagnosticosFiltrados.length,
                  itemBuilder: (context, index) {
                    final diagnostico = controller.diagnosticosFiltrados[index];
                    return _buildDiagnosticoCard(diagnostico);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticoCard(diagnostico) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(diagnostico),
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
                          'Fêmea: ${diagnostico.femeaBrinco ?? "Desconhecida"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          diagnostico.dataFormatada,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
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
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') {
                        controller.irParaFormulario(diagnostico);
                      } else if (value == 'excluir') {
                        controller.deletar(diagnostico);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    diagnostico.resultadoTexto,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: diagnostico.resultado
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  if (diagnostico.resultado &&
                      diagnostico.statusAlerta.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: diagnostico.diasRestantes != null &&
                                diagnostico.diasRestantes! <= 7
                            ? Colors.red.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        diagnostico.statusAlerta,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (diagnostico.dataPrevistaParto != null) ...[
                SizedBox(height: 8),
                Text(
                  'Previsão de parto: ${diagnostico.dataPrevistaFormatada}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 📦 ARQUIVO 11/14: diagnostico_form_view.dart

**Caminho:** `lib/presentation/views/diagnostico_form_view.dart`

```dart
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
        if (controller.coberturas.isEmpty) {
          return Center(child: CircularProgressIndicator());
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
```

---

## 📦 ARQUIVO 12/14: partos_view.dart

**Caminho:** `lib/presentation/views/partos_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/partos_controller.dart';

class PartosView extends GetView<PartosController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Partos'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.irParaFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.partosFiltrados.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.child_care, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Nenhum parto encontrado',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.carregarPartos,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: controller.partosFiltrados.length,
            itemBuilder: (context, index) {
              final parto = controller.partosFiltrados[index];
              return _buildPartoCard(parto);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPartoCard(parto) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => controller.irParaFormulario(parto),
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
                          'Mãe: ${parto.maeBrinco ?? "Desconhecida"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          parto.dataFormatada,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
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
                            Text('Excluir',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'editar') {
                        controller.irParaFormulario(parto);
                      } else if (value == 'excluir') {
                        controller.deletar(parto);
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
                        parto.resultadoTexto,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: parto.bezerrosVivos > 0
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      if (parto.tipoParto != null) ...[
                        SizedBox(height: 4),
                        Text(
                          parto.tipoPartoFormatado,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (parto.condicaoMae != null)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: parto.condicaoMae == 'boa'
                            ? Colors.green.shade50
                            : parto.condicaoMae == 'regular'
                                ? Colors.orange.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Mãe: ${parto.condicaoMaeFormatada}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              if (parto.diasGestacao != null) ...[
                SizedBox(height: 8),
                Text(
                  'Gestação: ${parto.diasGestacao} dias',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

---

Vou criar os 2 últimos arquivos no próximo artefato para completar!

**Faltam apenas 2 arquivos:**
- parto_form_view.dart
- relatorio_reproducao_view.dart

Me avise para eu criar os 2 finais! 🤰

# 🤰 MÓDULO REPRODUÇÃO - FINALIZAÇÃO PARTE 2
## Arquivos 13-14 (2 Views Finais)

---

## 📦 ARQUIVO 13/14: parto_form_view.dart

**Caminho:** `lib/presentation/views/parto_form_view.dart`

```dart
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
        if (controller.coberturas.isEmpty) {
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
```

---

## 📦 ARQUIVO 14/14: relatorio_reproducao_view.dart

**Caminho:** `lib/presentation/views/relatorio_reproducao_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/relatorio_reproducao_controller.dart';

class RelatorioReproducaoView extends GetView<RelatorioReproducaoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Relatório de Reprodução'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.carregarDados,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seletor de Período
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Período',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildPeriodoChip('30', '30 dias'),
                            _buildPeriodoChip('90', '90 dias'),
                            _buildPeriodoChip('180', '6 meses'),
                            _buildPeriodoChip('365', '1 ano'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Cards de Estatísticas
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Coberturas',
                        controller.totalCoberturas.value.toString(),
                        Icons.favorite,
                        Colors.pink,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Taxa Prenhez',
                        controller.taxaPrenhez Formatada,
                        Icons.pregnant_woman,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Monta Natural',
                        controller.montaNatural.value.toString(),
                        Icons.pets,
                        Colors.brown,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Inseminação',
                        controller.inseminacao.value.toString(),
                        Icons.science,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),

                // Prenhas Ativas
                Text(
                  'Prenhas Ativas (${controller.prenhasAtivas.length})',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                if (controller.prenhasAtivas.isEmpty)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Nenhuma fêmea prenha no momento',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  )
                else
                  ...controller.prenhasAtivas.map(
                    (prenha) => _buildPrenhaCard(prenha),
                  ),
                SizedBox(height: 24),

                // Estatísticas de Partos
                Obx(() {
                  if (controller.estatisticasPartos.isEmpty) {
                    return SizedBox();
                  }

                  final stats = controller.estatisticasPartos;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estatísticas de Partos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildStatRow(
                                'Total de Partos',
                                stats['total_partos']?.toString() ?? '0',
                              ),
                              Divider(),
                              _buildStatRow(
                                'Bezerros Vivos',
                                stats['bezerros_vivos']?.toString() ?? '0',
                                valueColor: Colors.green,
                              ),
                              _buildStatRow(
                                'Bezerros Mortos',
                                stats['bezerros_mortos']?.toString() ?? '0',
                                valueColor: Colors.red,
                              ),
                              _buildStatRow(
                                'Taxa de Sobrevivência',
                                controller.taxaSobrevivenciaFormatada,
                                valueColor: Colors.blue,
                              ),
                              Divider(),
                              _buildStatRow(
                                'Partos Normais',
                                stats['partos_normais']?.toString() ?? '0',
                              ),
                              _buildStatRow(
                                'Partos Assistidos',
                                stats['partos_assistidos']?.toString() ?? '0',
                              ),
                              _buildStatRow(
                                'Cesarianas',
                                stats['partos_cesariana']?.toString() ?? '0',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPeriodoChip(String valor, String label) {
    return Obx(() => ChoiceChip(
          label: Text(label),
          selected: controller.periodoSelecionado.value == valor,
          onSelected: (selected) {
            if (selected) {
              controller.mudarPeriodo(valor);
            }
          },
        ));
  }

  Widget _buildStatCard(
      String titulo, String valor, IconData icone, Color cor) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icone, size: 32, color: cor),
            SizedBox(height: 8),
            Text(
              valor,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            SizedBox(height: 4),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrenhaCard(prenha) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(Icons.pregnant_woman, color: Colors.blue.shade700),
        ),
        title: Text(prenha.femeaBrinco ?? 'Desconhecida'),
        subtitle: Text('Previsão: ${prenha.dataPrevistaFormatada}'),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: prenha.diasRestantes != null && prenha.diasRestantes! <= 7
                ? Colors.red.shade50
                : prenha.diasRestantes != null && prenha.diasRestantes! <= 30
                    ? Colors.orange.shade50
                    : Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            prenha.statusAlerta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ✅ PARTE 2 COMPLETA - 100%!

### 📊 RESUMO FINAL DA PARTE 2

**Total de arquivos criados: 14**

**Controllers (7):**
1. ✅ coberturas_controller.dart
2. ✅ cobertura_form_controller.dart
3. ✅ diagnosticos_controller.dart
4. ✅ diagnostico_form_controller.dart
5. ✅ partos_controller.dart
6. ✅ parto_form_controller.dart
7. ✅ relatorio_reproducao_controller.dart

**Views (7):**
8. ✅ coberturas_view.dart
9. ✅ cobertura_form_view.dart
10. ✅ diagnosticos_view.dart
11. ✅ diagnostico_form_view.dart
12. ✅ partos_view.dart
13. ✅ parto_form_view.dart
14. ✅ relatorio_reproducao_view.dart

---

## 🎁 FUNCIONALIDADES IMPLEMENTADAS

### ✅ Coberturas
- Registro de monta natural ou inseminação
- Vínculo com macho ou sêmen
- Lista com busca e filtros
- Menu de ações (editar/excluir)

### ✅ Diagnósticos de Prenhez
- Resultado: prenha ou vazia
- Data prevista de parto
- Método: palpação ou ultrassom
- Alertas automáticos (🔴🟡🟢)
- Filtro por resultado

### ✅ Partos
- Registro de bezerros vivos/mortos
- Tipo: normal, assistido, cesariana
- Condição da mãe: boa, regular, ruim
- Complicações e observações
- Vínculo opcional com cobertura

### ✅ Relatório Completo
- Total de coberturas
- Taxa de prenhez (%)
- Monta natural vs Inseminação
- Prenhas ativas com alertas
- Estatísticas de partos
- Taxa de sobrevivência
- Seletor de período

---

## 🎯 PRÓXIMO PASSO

Quando terminar de criar esses 14 arquivos, me avise:

> **"Parte 2 concluída. Próximo!"**

E eu crio a **Parte 3 Final** com:
- 🔗 Bindings (7 arquivos)
- 🛣️ Rotas configuradas
- 🏠 Integração com Home
- 📊 Roadmap atualizado

**Crie os 14 arquivos e me avise!** 🤰✨



# 🤰 MÓDULO REPRODUÇÃO - PARTE 3 FINAL
## Bindings, Rotas e Integração Completa

---

## 📁 ESTRUTURA DE ARQUIVOS

```
lib/
├── presentation/
│   └── bindings/
│       ├── coberturas_binding.dart             ← CRIAR
│       ├── cobertura_form_binding.dart         ← CRIAR
│       ├── diagnosticos_binding.dart           ← CRIAR
│       ├── diagnostico_form_binding.dart       ← CRIAR
│       ├── partos_binding.dart                 ← CRIAR
│       ├── parto_form_binding.dart             ← CRIAR
│       └── relatorio_reproducao_binding.dart   ← CRIAR
├── routes/
│   ├── app_routes.dart                         ← EDITAR
│   └── app_pages.dart                          ← EDITAR
└── presentation/views/
    └── home_view.dart                          ← EDITAR
```

**Total: 7 arquivos novos + 3 editados**

---

## 📦 ARQUIVO 1/10: coberturas_binding.dart

**Caminho:** `lib/presentation/bindings/coberturas_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/coberturas_controller.dart';

class CoberturasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoberturasController>(() => CoberturasController());
  }
}
```

---

## 📦 ARQUIVO 2/10: cobertura_form_binding.dart

**Caminho:** `lib/presentation/bindings/cobertura_form_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/cobertura_form_controller.dart';

class CoberturaFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoberturaFormController>(() => CoberturaFormController());
  }
}
```

---

## 📦 ARQUIVO 3/10: diagnosticos_binding.dart

**Caminho:** `lib/presentation/bindings/diagnosticos_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/diagnosticos_controller.dart';

class DiagnosticosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiagnosticosController>(() => DiagnosticosController());
  }
}
```

---

## 📦 ARQUIVO 4/10: diagnostico_form_binding.dart

**Caminho:** `lib/presentation/bindings/diagnostico_form_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/diagnostico_form_controller.dart';

class DiagnosticoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiagnosticoFormController>(() => DiagnosticoFormController());
  }
}
```

---

## 📦 ARQUIVO 5/10: partos_binding.dart

**Caminho:** `lib/presentation/bindings/partos_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/partos_controller.dart';

class PartosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartosController>(() => PartosController());
  }
}
```

---

## 📦 ARQUIVO 6/10: parto_form_binding.dart

**Caminho:** `lib/presentation/bindings/parto_form_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/parto_form_controller.dart';

class PartoFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartoFormController>(() => PartoFormController());
  }
}
```

---

## 📦 ARQUIVO 7/10: relatorio_reproducao_binding.dart

**Caminho:** `lib/presentation/bindings/relatorio_reproducao_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/relatorio_reproducao_controller.dart';

class RelatorioReproducaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatorioReproducaoController>(
        () => RelatorioReproducaoController());
  }
}
```

---

## 📦 ARQUIVO 8/10: app_routes.dart (EDITAR)

**Caminho:** `lib/routes/app_routes.dart`

**Adicione estas linhas no final da classe:**

```dart
abstract class AppRoutes {
  // ... rotas existentes ...
  
  // Rotas de Grupos
  static const GRUPOS = '/grupos';
  static const GRUPO_FORM = '/grupo-form';
  
  // Rotas de Animais
  static const ANIMAIS = '/animais';
  static const ANIMAL_FORM = '/animal-form';
  static const ANIMAL_DETALHES = '/animal-detalhes';
  
  // Rotas de Pesagem
  static const PESAGEM = '/pesagem';
  static const HISTORICO_PESAGEM = '/historico-pesagem';
  
  // Rotas de Saúde
  static const SAUDE = '/saude';
  static const HISTORICO_SAUDE = '/historico-saude';
  static const ALERTAS_SAUDE = '/alertas-saude';
  static const RELATORIO_SAUDE = '/relatorio-saude';
  
  // Rotas de Custos
  static const DESPESAS = '/despesas';
  static const DESPESA_FORM = '/despesa-form';
  static const RELATORIO_CUSTOS = '/relatorio-custos';
  
  // Rotas de Reprodução ← ADICIONAR ESTAS
  static const COBERTURAS = '/coberturas';
  static const COBERTURA_FORM = '/cobertura-form';
  static const DIAGNOSTICOS = '/diagnosticos';
  static const DIAGNOSTICO_FORM = '/diagnostico-form';
  static const PARTOS = '/partos';
  static const PARTO_FORM = '/parto-form';
  static const RELATORIO_REPRODUCAO = '/relatorio-reproducao';
  
  // Teste
  static const TESTE_CONEXAO = '/teste-conexao';
}
```

---

## 📦 ARQUIVO 9/10: app_pages.dart (EDITAR)

**Caminho:** `lib/routes/app_pages.dart`

**Adicione estes imports no início do arquivo:**

```dart
// ... imports existentes ...

// Reprodução ← ADICIONAR ESTES IMPORTS
import '../presentation/views/coberturas_view.dart';
import '../presentation/views/cobertura_form_view.dart';
import '../presentation/views/diagnosticos_view.dart';
import '../presentation/views/diagnostico_form_view.dart';
import '../presentation/views/partos_view.dart';
import '../presentation/views/parto_form_view.dart';
import '../presentation/views/relatorio_reproducao_view.dart';
import '../presentation/bindings/coberturas_binding.dart';
import '../presentation/bindings/cobertura_form_binding.dart';
import '../presentation/bindings/diagnosticos_binding.dart';
import '../presentation/bindings/diagnostico_form_binding.dart';
import '../presentation/bindings/partos_binding.dart';
import '../presentation/bindings/parto_form_binding.dart';
import '../presentation/bindings/relatorio_reproducao_binding.dart';
```

**Adicione estas páginas no array `pages`:**

```dart
class AppPages {
  static final pages = [
    // ... páginas existentes ...
    
    // Grupos
    GetPage(
      name: AppRoutes.GRUPOS,
      page: () => GruposView(),
      binding: GruposBinding(),
    ),
    // ... outras páginas de grupos ...
    
    // Animais
    GetPage(
      name: AppRoutes.ANIMAIS,
      page: () => AnimaisView(),
      binding: AnimaisBinding(),
    ),
    // ... outras páginas de animais ...
    
    // Pesagem
    GetPage(
      name: AppRoutes.PESAGEM,
      page: () => PesagemView(),
      binding: PesagemBinding(),
    ),
    // ... outras páginas de pesagem ...
    
    // Saúde
    GetPage(
      name: AppRoutes.SAUDE,
      page: () => SaudeView(),
      binding: SaudeBinding(),
    ),
    // ... outras páginas de saúde ...
    
    // Custos
    GetPage(
      name: AppRoutes.DESPESAS,
      page: () => DespesasView(),
      binding: DespesasBinding(),
    ),
    // ... outras páginas de custos ...
    
    // Reprodução ← ADICIONAR ESTAS PÁGINAS
    GetPage(
      name: AppRoutes.COBERTURAS,
      page: () => CoberturasView(),
      binding: CoberturasBinding(),
    ),
    GetPage(
      name: AppRoutes.COBERTURA_FORM,
      page: () => CoberturaFormView(),
      binding: CoberturaFormBinding(),
    ),
    GetPage(
      name: AppRoutes.DIAGNOSTICOS,
      page: () => DiagnosticosView(),
      binding: DiagnosticosBinding(),
    ),
    GetPage(
      name: AppRoutes.DIAGNOSTICO_FORM,
      page: () => DiagnosticoFormView(),
      binding: DiagnosticoFormBinding(),
    ),
    GetPage(
      name: AppRoutes.PARTOS,
      page: () => PartosView(),
      binding: PartosBinding(),
    ),
    GetPage(
      name: AppRoutes.PARTO_FORM,
      page: () => PartoFormView(),
      binding: PartoFormBinding(),
    ),
    GetPage(
      name: AppRoutes.RELATORIO_REPRODUCAO,
      page: () => RelatorioReproducaoView(),
      binding: RelatorioReproducaoBinding(),
    ),
    
    // Teste
    GetPage(
      name: AppRoutes.TESTE_CONEXAO,
      page: () => TesteConexaoView(),
      binding: TesteBinding(),
    ),
  ];
}
```

---

## 📦 ARQUIVO 10/10: home_view.dart (EDITAR)

**Caminho:** `lib/presentation/views/home_view.dart`

**Substitua o body do Scaffold por este código:**

```dart
body: Center(
  child: SingleChildScrollView(
    padding: EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Ícone
        Text(
          '🐄',
          style: TextStyle(fontSize: 80),
        ),
        SizedBox(height: 20),
        
        // Título
        Text(
          'Sistema de Gestão de Gado',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        
        // Botão Grupos
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/grupos'),
            icon: Icon(Icons.folder, size: 28),
            label: Text('Gerenciar Grupos', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Botão Animais
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/animais'),
            icon: Icon(Icons.pets, size: 28),
            label: Text('Gerenciar Animais', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Botão Pesagem
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/pesagem'),
            icon: Icon(Icons.monitor_weight, size: 28),
            label: Text('Registrar Pesagem', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Botão Saúde
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/saude'),
            icon: Icon(Icons.medical_services, size: 28),
            label: Text('Registrar Saúde', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Botão Despesas
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/despesas'),
            icon: Icon(Icons.attach_money, size: 28),
            label: Text('Gerenciar Despesas', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // Botão Reprodução ← NOVO BOTÃO
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed('/coberturas'),
            icon: Icon(Icons.pregnant_woman, size: 28),
            label: Text('Reprodução', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: 32),
        
        // Botões Secundários
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão Alertas
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/alertas-saude'),
              icon: Icon(Icons.notifications, size: 20),
              label: Text('Alertas'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(width: 12),
            
            // Botão Relatórios ← ATUALIZADO
            OutlinedButton.icon(
              onPressed: _mostrarRelatorios,
              icon: Icon(Icons.assessment, size: 20),
              label: Text('Relatórios'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(width: 12),
            
            // Botão Teste
            OutlinedButton.icon(
              onPressed: controller.irParaTeste,
              icon: Icon(Icons.wifi, size: 20),
              label: Text('Teste'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

// Adicione este método na classe HomeView:
void _mostrarRelatorios() {
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
            'Relatórios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.attach_money, color: Colors.purple),
            title: Text('Relatório de Custos'),
            onTap: () {
              Get.back();
              Get.toNamed('/relatorio-custos');
            },
          ),
          ListTile(
            leading: Icon(Icons.pregnant_woman, color: Colors.pink),
            title: Text('Relatório de Reprodução'),
            onTap: () {
              Get.back();
              Get.toNamed('/relatorio-reproducao');
            },
          ),
          ListTile(
            leading: Icon(Icons.medical_services, color: Colors.red),
            title: Text('Relatório de Saúde'),
            onTap: () {
              Get.back();
              Get.toNamed('/relatorio-saude');
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## ✅ PARTE 3 COMPLETA - 100%!

### 📊 RESUMO FINAL

**Arquivos criados: 7 bindings**
1. ✅ coberturas_binding.dart
2. ✅ cobertura_form_binding.dart
3. ✅ diagnosticos_binding.dart
4. ✅ diagnostico_form_binding.dart
5. ✅ partos_binding.dart
6. ✅ parto_form_binding.dart
7. ✅ relatorio_reproducao_binding.dart

**Arquivos editados: 3**
8. ✅ app_routes.dart - 7 rotas adicionadas
9. ✅ app_pages.dart - 7 páginas configuradas
10. ✅ home_view.dart - Botão rosa + menu relatórios

---

## 🎉 MÓDULO REPRODUÇÃO - 100% COMPLETO!

### 📦 TOTAL DE ARQUIVOS DO MÓDULO

**Parte 1 (Models e Services): 6 arquivos**
- cobertura_model.dart
- diagnostico_prenhez_model.dart
- parto_model.dart
- cobertura_service.dart
- diagnostico_prenhez_service.dart
- parto_service.dart

**Parte 2 (Controllers e Views): 14 arquivos**
- coberturas_controller.dart
- cobertura_form_controller.dart
- diagnosticos_controller.dart
- diagnostico_form_controller.dart
- partos_controller.dart
- parto_form_controller.dart
- relatorio_reproducao_controller.dart
- coberturas_view.dart
- cobertura_form_view.dart
- diagnosticos_view.dart
- diagnostico_form_view.dart
- partos_view.dart
- parto_form_view.dart
- relatorio_reproducao_view.dart

**Parte 3 (Bindings e Integração): 10 arquivos**
- 7 bindings
- 3 arquivos editados

**Total: 30 arquivos criados/editados** ✅

---

## 🎁 FUNCIONALIDADES COMPLETAS

### ✅ Coberturas
- Registro de monta natural ou IA
- Busca por fêmea
- Menu para diagnósticos e partos
- Estatísticas no relatório

### ✅ Diagnósticos
- Resultado prenha/vazia
- Data prevista de parto
- Alertas automáticos (🔴🟡🟢)
- Taxa de prenhez calculada

### ✅ Partos
- Bezerros vivos/mortos
- Tipo de parto
- Condição da mãe
- Taxa de sobrevivência

### ✅ Relatório Completo
- Total de coberturas
- Monta natural vs IA
- Taxa de prenhez
- Prenhas ativas com alertas
- Estatísticas de partos
- Taxa de sobrevivência

### ✅ Integrações
- Botão rosa "Reprodução" na Home
- Menu "Relatórios" com todas opções
- Navegação entre módulos
- Bottom sheet de relatórios

---

## 🧪 TESTE COMPLETO (15 min)

### **1. Registrar Cobertura** (2 min)
```
Home → "Reprodução"
"+" → Nova Cobertura
Fêmea: selecionar
Tipo: 🐂 Monta Natural
Macho: selecionar
Data: hoje
Salvar
✅ "Cobertura registrada com sucesso!"
```

### **2. Fazer Diagnóstico** (2 min)
```
Botão "Diagnósticos"
"+" → Novo Diagnóstico
Cobertura: selecionar a criada
Data: 45 dias depois
Resultado: ✅ Prenha
Método: Ultrassom
Data Prevista: calcular ~280 dias
Salvar
✅ "Diagnóstico registrado!"
```

### **3. Ver Alertas** (1 min)
```
Voltar para Diagnósticos
✅ Ver status com dias restantes
Se < 30 dias: 🟢 Próximo
Se < 7 dias: 🟡 Urgente
```

### **4. Registrar Parto** (2 min)
```
Botão "Partos"
"+" → Novo Parto
Cobertura: opcional
Data: data prevista
Bezerros Vivos: 1
Tipo: ✅ Normal
Condição Mãe: 🟢 Boa
Salvar
✅ "Parto registrado!"
```

### **5. Ver Relatório** (3 min)
```
Home → "Relatórios" → "Relatório de Reprodução"
✅ Ver total de coberturas
✅ Ver taxa de prenhez
✅ Ver estatísticas de partos
✅ Ver prenhas ativas

Mudar período para 1 ano
✅ Dados atualizam
```

### **6. Testar Navegação** (2 min)
```
Coberturas → "Diagnósticos"
Diagnósticos → Voltar → "Partos"
Partos → Menu Relatório
✅ Navegação fluida
```

### **7. Editar e Excluir** (3 min)
```
Editar cobertura → Mudar observações
Excluir diagnóstico → Confirmar
✅ Operações funcionam
```

---

## 🎉 PROGRESSO FINAL

```
✅ Setup Inicial (100%)
✅ Grupos (100%)
✅ Animais (100%)
✅ Pesagem + GMD (100%)
✅ Saúde + Alertas (100%)
✅ Custos + Despesas (100%)
✅ Reprodução Completa (100%) ← NOVO!
⬜ Dashboard (0%)

Progresso Geral: 88% 🎯
```

**FALTA APENAS 1 MÓDULO: Dashboard!**

---

## 🚀 EXECUTAR E TESTAR

```bash
flutter run -d chrome
# ou pressione 'r'
```

**Fluxo de teste:**
1. Home → "Reprodução"
2. Criar cobertura
3. Fazer diagnóstico
4. Ver alertas
5. Registrar parto
6. Ver relatório completo

---

## 💬 ME RESPONDA

Após criar todos os arquivos e testar:

**Opção 1 (tudo OK):**
> "Módulo Reprodução testado! Tudo funcionando. Vamos para Dashboard?"

**Opção 2 (algum erro):**
> "Erro: [descreva o erro]"

**Opção 3 (finalizar projeto):**
> "Sistema completo! Vamos revisar tudo."

---

## 🎯 PRÓXIMO E ÚLTIMO MÓDULO

**📊 Dashboard** - Visão geral do sistema
- KPIs principais
- Gráficos
- Resumos
- Alertas consolidados

**Ou podemos:**
- 🧪 Fazer testes completos
- 🎨 Melhorar UI/UX
- 📱 Testar em outras plataformas
- 📝 Criar documentação

**Crie os 10 arquivos da Parte 3 e me avise o resultado!** 🤰✨