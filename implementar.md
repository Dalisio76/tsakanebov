# 💰 MÓDULO CUSTOS - PARTE 3 FINAL
## Bindings, Rotas e Integração Completa

---

## 📁 ESTRUTURA DE ARQUIVOS

```
lib/
├── presentation/
│   └── bindings/
│       ├── despesas_binding.dart          ← CRIAR
│       ├── despesa_form_binding.dart      ← CRIAR
│       └── relatorio_custos_binding.dart  ← CRIAR
├── routes/
│   ├── app_routes.dart                    ← EDITAR
│   └── app_pages.dart                     ← EDITAR
└── presentation/views/
    ├── home_view.dart                     ← EDITAR
    ├── animal_detalhes_view.dart          ← EDITAR (opcional)
    └── animais_view.dart                  ← EDITAR (opcional)
```

**Total: 3 arquivos novos + 5 editados**

---

## 📦 ARQUIVO 1/8: despesas_binding.dart

**Caminho:** `lib/presentation/bindings/despesas_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/despesas_controller.dart';

class DespesasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DespesasController>(() => DespesasController());
  }
}
```

---

## 📦 ARQUIVO 2/8: despesa_form_binding.dart

**Caminho:** `lib/presentation/bindings/despesa_form_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/despesa_form_controller.dart';

class DespesaFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DespesaFormController>(() => DespesaFormController());
  }
}
```

---

## 📦 ARQUIVO 3/8: relatorio_custos_binding.dart

**Caminho:** `lib/presentation/bindings/relatorio_custos_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/relatorio_custos_controller.dart';

class RelatorioCustosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatorioCustosController>(() => RelatorioCustosController());
  }
}
```

---

## 📦 ARQUIVO 4/8: app_routes.dart (EDITAR)

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
  
  // Rotas de Custos ← ADICIONAR ESTAS
  static const DESPESAS = '/despesas';
  static const DESPESA_FORM = '/despesa-form';
  static const RELATORIO_CUSTOS = '/relatorio-custos';
  
  // Teste
  static const TESTE_CONEXAO = '/teste-conexao';
}
```

---

## 📦 ARQUIVO 5/8: app_pages.dart (EDITAR)

**Caminho:** `lib/routes/app_pages.dart`

**Adicione estes imports no início do arquivo:**

```dart
// ... imports existentes ...

// Custos ← ADICIONAR ESTES IMPORTS
import '../presentation/views/despesas_view.dart';
import '../presentation/views/despesa_form_view.dart';
import '../presentation/views/relatorio_custos_view.dart';
import '../presentation/bindings/despesas_binding.dart';
import '../presentation/bindings/despesa_form_binding.dart';
import '../presentation/bindings/relatorio_custos_binding.dart';
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
    
    // Custos ← ADICIONAR ESTAS PÁGINAS
    GetPage(
      name: AppRoutes.DESPESAS,
      page: () => DespesasView(),
      binding: DespesasBinding(),
    ),
    GetPage(
      name: AppRoutes.DESPESA_FORM,
      page: () => DespesaFormView(),
      binding: DespesaFormBinding(),
    ),
    GetPage(
      name: AppRoutes.RELATORIO_CUSTOS,
      page: () => RelatorioCustosView(),
      binding: RelatorioCustosBinding(),
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

## 📦 ARQUIVO 6/8: home_view.dart (EDITAR)

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
        
        // Botão Despesas ← NOVO BOTÃO
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
            
            // Botão Relatórios ← NOVO BOTÃO
            OutlinedButton.icon(
              onPressed: () => Get.toNamed('/relatorio-custos'),
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
```

---

## 📦 ARQUIVO 7/8: animal_detalhes_view.dart (EDITAR - OPCIONAL)

**Caminho:** `lib/presentation/views/animal_detalhes_view.dart`

**Adicione este botão antes do último `SizedBox(height: 16)`:**

```dart
// Antes do último SizedBox(height: 16), adicione:

// Botão Ver Custos
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16.0),
  child: ElevatedButton.icon(
    onPressed: () {
      // Navegar para despesas filtradas por este animal
      Get.toNamed('/despesas'); // Você pode passar o animal como argumento
    },
    icon: Icon(Icons.attach_money),
    label: Text('Ver Custos deste Animal'),
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.purple,
      minimumSize: Size(double.infinity, 50),
    ),
  ),
),
SizedBox(height: 16),
```

---

## 📦 ARQUIVO 8/8: animais_view.dart (EDITAR - OPCIONAL)

**Caminho:** `lib/presentation/views/animais_view.dart`

**No `PopupMenuButton`, adicione esta opção:**

```dart
PopupMenuButton(
  itemBuilder: (context) => [
    // ... opções existentes ...
    
    PopupMenuItem(
      value: 'detalhes',
      child: Row(
        children: [
          Icon(Icons.info, size: 20),
          SizedBox(width: 8),
          Text('Detalhes'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'historico_peso',
      child: Row(
        children: [
          Icon(Icons.timeline, size: 20),
          SizedBox(width: 8),
          Text('Histórico de Peso'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'historico_saude',
      child: Row(
        children: [
          Icon(Icons.medical_services, size: 20),
          SizedBox(width: 8),
          Text('Histórico de Saúde'),
        ],
      ),
    ),
    // ADICIONAR ESTA OPÇÃO ←
    PopupMenuItem(
      value: 'custos',
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 20, color: Colors.purple),
          SizedBox(width: 8),
          Text('Custos', style: TextStyle(color: Colors.purple)),
        ],
      ),
    ),
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
          Text('Excluir', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
  onSelected: (value) {
    if (value == 'detalhes') {
      controller.irParaDetalhes(animal);
    } else if (value == 'historico_peso') {
      Get.toNamed('/historico-pesagem', arguments: animal);
    } else if (value == 'historico_saude') {
      Get.toNamed('/historico-saude', arguments: animal);
    } else if (value == 'custos') {
      // ADICIONAR ESTA AÇÃO ←
      Get.toNamed('/despesas'); // Pode passar animal como argumento para filtrar
    } else if (value == 'editar') {
      controller.irParaFormulario(animal);
    } else if (value == 'excluir') {
      controller.confirmarExclusao(animal);
    }
  },
),
```

---

## ✅ PARTE 3 COMPLETA!

### 📊 RESUMO FINAL

**Arquivos criados: 3**
1. ✅ `despesas_binding.dart`
2. ✅ `despesa_form_binding.dart`
3. ✅ `relatorio_custos_binding.dart`

**Arquivos editados: 5**
4. ✅ `app_routes.dart` - Rotas adicionadas
5. ✅ `app_pages.dart` - Páginas configuradas
6. ✅ `home_view.dart` - Botão roxo de despesas
7. ✅ `animal_detalhes_view.dart` - Botão custos (opcional)
8. ✅ `animais_view.dart` - Menu custos (opcional)

---

## 🎯 MÓDULO CUSTOS - COMPLETO! 

### 📦 TOTAL DE ARQUIVOS

**Parte 1 (Models e Services): 4 arquivos**
- categoria_custo_model.dart
- despesa_model.dart
- categoria_custo_service.dart
- despesa_service.dart

**Parte 2 (Controllers e Views): 6 arquivos**
- despesas_controller.dart
- despesa_form_controller.dart
- relatorio_custos_controller.dart
- despesas_view.dart
- despesa_form_view.dart
- relatorio_custos_view.dart

**Parte 3 (Bindings e Integração): 8 arquivos**
- despesas_binding.dart
- despesa_form_binding.dart
- relatorio_custos_binding.dart
- app_routes.dart (editado)
- app_pages.dart (editado)
- home_view.dart (editado)
- animal_detalhes_view.dart (editado - opcional)
- animais_view.dart (editado - opcional)

**Total: 18 arquivos** ✅

---

## 🎁 FUNCIONALIDADES IMPLEMENTADAS

### ✅ Lista de Despesas
- Busca em tempo real
- Filtro por período
- Card de total destacado
- Menu de ações (editar/excluir)
- Pull to refresh

### ✅ Formulário de Despesas
- Campos obrigatórios: descrição, valor, data
- Opcionais: categoria, quantidade, unidade, fornecedor, nota fiscal
- Vinculação: nenhum, animal ou grupo
- Validações completas
- Modo criação e edição

### ✅ Relatório de Custos
- Total gasto no período
- Estatísticas por categoria (valor e %)
- Barras de progresso visuais
- Despesas detalhadas agrupadas
- Seletor de período (7, 30, 90, 365 dias)

### ✅ Integrações
- Botão roxo na Home
- Menu de custos nos animais
- Botão de custos nos detalhes do animal
- Botão de relatórios na Home

---

## 🧪 TESTE COMPLETO (10 min)

### **1. Registrar Primeira Despesa** (2 min)
```
Home → "Gerenciar Despesas" → "+"
Descrição: Ração concentrado
Categoria: Ração/Concentrado
Valor: 450.00
Data: Hoje
Vinculação: Grupo → Engorda - Lote 1
Quantidade: 50
Unidade: kg
Salvar
✅ "Despesa registrada com sucesso!"
```

### **2. Registrar Despesa com Animal** (2 min)
```
"+" → Nova despesa
Descrição: Vacina Aftosa
Categoria: Vacinas
Valor: 45.00
Data: Hoje
Vinculação: Animal → 001
Salvar
✅ Aparece na lista
```

### **3. Buscar e Filtrar** (2 min)
```
Buscar: "ração"
✅ Filtra automaticamente

Filtros → Período: 7 dias
✅ Mostra apenas últimos 7 dias

Total atualiza automaticamente
```

### **4. Editar Despesa** (1 min)
```
Menu (3 pontos) → Editar
Mudar valor para 460.00
Salvar
✅ "Despesa atualizada!"
```

### **5. Ver Relatório** (2 min)
```
Ícone assessment (topo) → Relatório de Custos
✅ Ver total gasto
✅ Ver gráfico por categoria
✅ Ver despesas detalhadas

Mudar período para 30 dias
✅ Dados atualizam
```

### **6. Excluir Despesa** (1 min)
```
Menu → Excluir
Confirmar
✅ "Despesa excluída com sucesso!"
```

---

## 🎉 PROGRESSO ATUALIZADO

```
✅ Setup Inicial (100%)
✅ Grupos (100%)
✅ Animais (100%)
✅ Pesagem + GMD (100%)
✅ Saúde + Alertas (100%)
✅ Custos + Despesas (100%) ← NOVO!
⬜ Reprodução (0%)
⬜ Dashboard (0%)

Progresso Geral: 75% 🎯
```

---

## 🚀 EXECUTAR E TESTAR

```bash
flutter run -d chrome
# ou pressione 'r' se já estiver rodando
```

---

## 💬 ME RESPONDA

Após criar todos os arquivos e testar:

**Opção 1 (tudo OK):**
> "Módulo Custos testado! Tudo funcionando. Qual próximo?"

**Opção 2 (algum erro):**
> "Erro: [descreva o erro]"

---

## 🎯 PRÓXIMOS MÓDULOS DISPONÍVEIS

1. **🤰 Reprodução** - Coberturas + Prenhez + Partos
2. **📊 Dashboard** - Visão geral + Gráficos + KPIs

**Ou:**
- 🧪 Testar tudo profundamente
- 🎨 Melhorias de UI/UX
- 📱 Testar em Android/Desktop

**Crie os arquivos da Parte 3 e me avise o resultado!** 💰✨