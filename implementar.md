# 🔧 AJUSTES + UPLOAD CLOUDINARY

## 📦 TOTAL: 9 arquivos (2 novos + 7 editar)

---

## 1️⃣ ADICIONAR "MARCAR PARA ABATE" NO MENU

### Editar `lib/presentation/views/animais_view.dart`

**Localizar o PopupMenuButton (linha ~180):**

```dart
// ANTES:
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'editar') {
      controller.irParaEdicao(animal);
    } else if (value == 'detalhes') {
      controller.irParaDetalhes(animal);
    } else if (value == 'historico') {
      controller.irParaDetalhes(animal);
      Get.toNamed('/historico-pesagem', arguments: animal);
    } else if (value == 'morto') {
      _marcarComoMorto(animal);
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'detalhes',
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 8),
          Text('Ver Detalhes'),
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
      value: 'historico',
      child: Row(
        children: [
          Icon(Icons.timeline, size: 20),
          SizedBox(width: 8),
          Text('Histórico de Peso'),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'morto',
      child: Row(
        children: [
          Icon(Icons.heart_broken, size: 20, color: Colors.red),
          SizedBox(width: 8),
          Text('Marcar como Morto', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
),

// DEPOIS (ADICIONAR ITEM):
PopupMenuButton<String>(
  onSelected: (value) {
    if (value == 'editar') {
      controller.irParaEdicao(animal);
    } else if (value == 'detalhes') {
      controller.irParaDetalhes(animal);
    } else if (value == 'historico') {
      controller.irParaDetalhes(animal);
      Get.toNamed('/historico-pesagem', arguments: animal);
    } else if (value == 'morto') {
      _marcarComoMorto(animal);
    } else if (value == 'abate') { // ← ADICIONAR
      _marcarParaAbate(animal);
    }
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 'detalhes',
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 8),
          Text('Ver Detalhes'),
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
      value: 'historico',
      child: Row(
        children: [
          Icon(Icons.timeline, size: 20),
          SizedBox(width: 8),
          Text('Histórico de Peso'),
        ],
      ),
    ),
    // ← ADICIONAR ESTE ITEM
    PopupMenuItem(
      value: 'abate',
      child: Row(
        children: [
          Icon(Icons.restaurant, size: 20, color: Colors.brown),
          SizedBox(width: 8),
          Text('Marcar para Abate', style: TextStyle(color: Colors.brown)),
        ],
      ),
    ),
    PopupMenuItem(
      value: 'morto',
      child: Row(
        children: [
          Icon(Icons.heart_broken, size: 20, color: Colors.red),
          SizedBox(width: 8),
          Text('Marcar como Morto', style: TextStyle(color: Colors.red)),
        ],
      ),
    ),
  ],
),
```

**Adicionar método _marcarParaAbate (após o método _marcarComoMorto):**

```dart
// Adicionar este método no final da classe, antes do último }
void _marcarParaAbate(AnimalModel animal) {
  Get.defaultDialog(
    title: 'Marcar para Abate',
    middleText: 'Tem certeza que deseja marcar o animal ${animal.brinco} para abate?',
    textConfirm: 'Sim, marcar',
    textCancel: 'Cancelar',
    confirmTextColor: Colors.white,
    buttonColor: Colors.brown,
    onConfirm: () async {
      Get.back(); // Fecha diálogo
      
      try {
        await controller.animalService.atualizar(
          animal.id!,
          animal.copyWith(status: 'abate'),
        );
        
        Get.snackbar(
          '✅ Sucesso',
          'Animal marcado para abate',
          backgroundColor: Colors.brown,
          colorText: Colors.white,
        );
        
        controller.listarAnimais();
      } catch (e) {
        Get.snackbar(
          '❌ Erro',
          'Erro ao marcar animal: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    },
  );
}
```

---

## 2️⃣ MUDAR MOEDA PARA METICAL (MT)

### A. Criar helper de formatação

#### Criar `lib/core/utils/currency_helper.dart`

```dart
import 'package:intl/intl.dart';

class CurrencyHelper {
  // Formatar como Metical
  static String formatMT(double valor) {
    return 'MT ${NumberFormat('#,##0.00', 'pt_BR').format(valor)}';
  }
  
  // Formatar peso
  static String formatPeso(double peso) {
    return '${NumberFormat('#,##0.0', 'pt_BR').format(peso)} kg';
  }
  
  // Formatar GMD
  static String formatGMD(double gmd) {
    return '${NumberFormat('#,##0.000', 'pt_BR').format(gmd)} kg/dia';
  }
  
  // Formatar número com separador de milhares
  static String formatNumber(double numero) {
    return NumberFormat('#,##0', 'pt_BR').format(numero);
  }
}
```

---

### B. Atualizar Dashboard

#### Editar `lib/presentation/controllers/dashboard_controller.dart`

```dart
// Importar helper no topo
import '../../core/utils/currency_helper.dart';

// Substituir métodos de formatação (linha ~80)
// REMOVER:
String formatarMoeda(double valor) {
  return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
}

// ADICIONAR:
String formatarMoeda(double valor) {
  return CurrencyHelper.formatMT(valor);
}

String formatarPeso(double peso) {
  return CurrencyHelper.formatPeso(peso);
}

String formatarGMD(double gmd) {
  return CurrencyHelper.formatGMD(gmd);
}
```

---

### C. Atualizar View de Abate

#### Editar `lib/presentation/views/animais_abate_view.dart`

**Importar helper no topo:**

```dart
import '../../core/utils/currency_helper.dart';
```

**Localizar linha ~75 (valor estimado no header):**

```dart
// ANTES:
'Valor estimado: R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(arrobasTotal * 300)}',

// DEPOIS:
'Valor estimado: ${CurrencyHelper.formatMT(arrobasTotal * 300)}',
```

**Localizar linha ~180 (valor por animal):**

```dart
// ANTES:
'Est. R\$ ${NumberFormat('#,##0.00', 'pt_BR').format(arrobas * 300)}',

// DEPOIS:
'Est. ${CurrencyHelper.formatMT(arrobas * 300)}',
```

---

### D. Atualizar Dashboard View

#### Editar `lib/presentation/views/dashboard_view.dart`

**Importar helper no topo:**

```dart
import '../../core/utils/currency_helper.dart';
```

**Localizar KPI de valor da arroba (linha ~80):**

```dart
// ANTES:
valor: 'R\$ ${stats.valorArrobaAtual.toStringAsFixed(2)}',

// DEPOIS:
valor: CurrencyHelper.formatMT(stats.valorArrobaAtual),
```

---

## 3️⃣ UPLOAD DE IMAGENS COM CLOUDINARY

### A. Adicionar dependências

#### Editar `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  supabase_flutter: ^2.5.0
  intl: ^0.19.0
  fl_chart: ^0.68.0
  http: ^1.1.0              # ← ADICIONAR
  image_picker: ^1.0.4      # ← ADICIONAR
```

**Executar:**

```bash
flutter pub get
```

---

### B. Criar serviço Cloudinary

#### Criar `lib/core/services/cloudinary_service.dart`

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // 🔐 SUAS CREDENCIAIS DO CLOUDINARY
  // Obtenha em: https://cloudinary.com/console
  static const String cloudName = 'SEU_CLOUD_NAME';  // ← MUDAR
  static const String uploadPreset = 'SEU_PRESET';   // ← MUDAR
  
  // Upload de imagem para Cloudinary
  static Future<String?> uploadImagem({
    required Uint8List bytes,
    required String filename,
    String folder = 'gestao-gado/animais',
  }) async {
    try {
      print('📤 Iniciando upload para Cloudinary...');
      
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload'
      );

      final request = http.MultipartRequest('POST', url);
      
      // Configurações do upload
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      request.fields['resource_type'] = 'image';
      
      // Adicionar arquivo
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      print('📡 Enviando para Cloudinary...');
      final response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = json.decode(responseString);
        
        final imageUrl = jsonMap['secure_url'] as String;
        print('✅ Upload bem-sucedido: $imageUrl');
        
        return imageUrl;
      } else {
        print('❌ Erro no upload: ${response.statusCode}');
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        print('Resposta: $responseString');
        return null;
      }
    } catch (e) {
      print('❌ Erro ao fazer upload: $e');
      return null;
    }
  }

  // Upload de múltiplas imagens
  static Future<List<String>> uploadMultiplasImagens({
    required List<Uint8List> bytesList,
    required List<String> filenames,
    String folder = 'gestao-gado/animais',
  }) async {
    List<String> urls = [];
    
    for (int i = 0; i < bytesList.length; i++) {
      final url = await uploadImagem(
        bytes: bytesList[i],
        filename: filenames[i],
        folder: folder,
      );
      
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }
}
```

---

### C. Configurar Cloudinary

**PASSO A PASSO:**

1. **Criar conta grátis:**
   - Acesse: https://cloudinary.com
   - Sign Up (grátis)

2. **Pegar credenciais:**
   - Dashboard → Cloud Name (ex: "dxxx")
   - Settings → Upload → Upload Presets → Add upload preset
   - Nome: "gestao-gado"
   - Signing Mode: Unsigned
   - Salvar

3. **Atualizar código:**
   ```dart
   static const String cloudName = 'seu_cloud_name_aqui';
   static const String uploadPreset = 'gestao-gado';
   ```

---

### D. Adicionar upload no controller

#### Editar `lib/presentation/controllers/animal_form_controller.dart`

**Adicionar no topo:**

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../core/services/cloudinary_service.dart';
```

**Adicionar variáveis observáveis (após as outras variáveis):**

```dart
var isUploadingImage = false.obs;
var imagemSelecionada = Rx<Uint8List?>(null);
```

**Adicionar método de seleção e upload:**

```dart
// Método para selecionar e fazer upload da foto
Future<void> selecionarEUploadFoto() async {
  try {
    final picker = ImagePicker();
    
    // Selecionar imagem
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image == null) {
      print('❌ Nenhuma imagem selecionada');
      return;
    }

    print('📸 Imagem selecionada: ${image.name}');
    
    // Ler bytes da imagem
    final bytes = await image.readAsBytes();
    imagemSelecionada.value = bytes;
    
    // Mostrar preview e iniciar upload
    isUploadingImage.value = true;
    
    Get.snackbar(
      '⏳ Enviando',
      'Fazendo upload da imagem...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );

    // Upload para Cloudinary
    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await CloudinaryService.uploadImagem(
      bytes: bytes,
      filename: filename,
    );
    
    if (url != null) {
      urlImagemController.text = url;
      
      Get.snackbar(
        '✅ Sucesso',
        'Foto enviada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      imagemSelecionada.value = null;
      
      Get.snackbar(
        '❌ Erro',
        'Erro ao enviar foto. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    print('❌ Erro ao selecionar foto: $e');
    imagemSelecionada.value = null;
    
    Get.snackbar(
      '❌ Erro',
      'Erro ao selecionar foto: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isUploadingImage.value = false;
  }
}

// Método para tirar foto com câmera
Future<void> tirarFoto() async {
  try {
    final picker = ImagePicker();
    
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    
    if (image == null) return;

    final bytes = await image.readAsBytes();
    imagemSelecionada.value = bytes;
    
    isUploadingImage.value = true;
    
    Get.snackbar(
      '⏳ Enviando',
      'Fazendo upload da imagem...',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );

    final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await CloudinaryService.uploadImagem(
      bytes: bytes,
      filename: filename,
    );
    
    if (url != null) {
      urlImagemController.text = url;
      
      Get.snackbar(
        '✅ Sucesso',
        'Foto enviada com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      imagemSelecionada.value = null;
      
      Get.snackbar(
        '❌ Erro',
        'Erro ao enviar foto.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } catch (e) {
    print('❌ Erro ao tirar foto: $e');
    imagemSelecionada.value = null;
    
    Get.snackbar(
      '❌ Erro',
      'Erro: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  } finally {
    isUploadingImage.value = false;
  }
}

// Remover imagem selecionada
void removerImagem() {
  imagemSelecionada.value = null;
  urlImagemController.clear();
}
```

**Atualizar método limparFormulario:**

```dart
void limparFormulario() {
  brincoController.clear();
  nomeController.clear();
  // ... outros clears ...
  imagemSelecionada.value = null;  // ← ADICIONAR
  urlImagemController.clear();
  
  // ... resto do método
}
```

---

### E. Atualizar formulário de animal

#### Editar `lib/presentation/views/animal_form_view.dart`

**Adicionar import no topo:**

```dart
import 'dart:typed_data';
```

**Localizar seção de imagem (linha ~250) e SUBSTITUIR por:**

```dart
// Imagem
SizedBox(height: 16),
Text(
  'Foto do Animal',
  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
SizedBox(height: 8),

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
      child: Center(
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
              icon: Icon(Icons.close, color: Colors.white),
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
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.error, size: 48, color: Colors.red),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
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
      border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Nenhuma foto selecionada',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    ),
  );
}),

SizedBox(height: 12),

// Botões de upload
Row(
  children: [
    Expanded(
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isUploadingImage.value
            ? null
            : controller.selecionarEUploadFoto,
        icon: Icon(Icons.photo_library),
        label: Text('Galeria'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
      )),
    ),
    SizedBox(width: 12),
    Expanded(
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isUploadingImage.value
            ? null
            : controller.tirarFoto,
        icon: Icon(Icons.camera_alt),
        label: Text('Câmera'),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.green,
        ),
      )),
    ),
  ],
),
```

---

## ✅ CHECKLIST COMPLETO

### 1. Marcar para Abate:
- [ ] Editar `animais_view.dart` (adicionar item menu)
- [ ] Adicionar método `_marcarParaAbate`

### 2. Moeda Metical:
- [ ] Criar `currency_helper.dart`
- [ ] Editar `dashboard_controller.dart`
- [ ] Editar `animais_abate_view.dart`
- [ ] Editar `dashboard_view.dart`

### 3. Upload Cloudinary:
- [ ] Adicionar dependências no `pubspec.yaml`
- [ ] Executar `flutter pub get`
- [ ] Criar conta Cloudinary
- [ ] Criar `cloudinary_service.dart`
- [ ] Configurar credenciais
- [ ] Editar `animal_form_controller.dart`
- [ ] Editar `animal_form_view.dart`

---

## 🧪 TESTES

### 1. Marcar Abate:
- Ir em Animais
- Clicar nos 3 pontinhos
- Ver "Marcar para Abate" ✅
- Confirmar
- Ver em "Animais para Abate" ✅

### 2. Moeda:
- Dashboard → Ver "MT" ao invés de "R$" ✅
- Animais Abate → Ver valores em MT ✅

### 3. Upload:
- Criar/Editar animal
- Clicar "Galeria" → Selecionar foto
- Ver preview ✅
- Ver loading enquanto envia ✅
- Ver "✅ Foto enviada" ✅
- Salvar animal
- Ver foto nos detalhes ✅

---

## 🔐 CONFIGURAR CLOUDINARY

### Passo 1: Criar conta
```
https://cloudinary.com
→ Sign Up (grátis)
```

### Passo 2: Pegar Cloud Name
```
Dashboard → Cloud Name
Exemplo: "dqwerty123"
```

### Passo 3: Criar Upload Preset
```
Settings → Upload → Upload Presets
→ Add upload preset
Nome: gestao-gado
Signing Mode: Unsigned
→ Save
```

### Passo 4: Atualizar código
```dart
// Em cloudinary_service.dart
static const String cloudName = 'seu_cloud_name';
static const String uploadPreset = 'gestao-gado';
```

---

## 💡 RECURSOS DO UPLOAD

✅ **Galeria** - Escolher foto existente
✅ **Câmera** - Tirar foto na hora
✅ **Preview** - Ver antes de salvar
✅ **Loading** - Indicador de progresso
✅ **Compressão** - Otimiza tamanho (max 1080p)
✅ **Qualidade** - 85% (balanço tamanho/qualidade)
✅ **Validação** - Mensagens de erro claras
✅ **Remover** - Botão X para desfazer

---

## 🎯 PERMISSÕES (Android/iOS)

### Android - Adicionar em `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS - Adicionar em `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos para você adicionar imagens dos animais</string>
<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera para você tirar fotos dos animais</string>
```

---

## 💬 QUANDO TERMINAR

Me avise:

> "Ajustes aplicados! Upload funcionando!"

Ou:

> "Dúvida/Erro em [parte específica]"

---

## 🎉 PRÓXIMOS PASSOS

Depois disso temos:
1. ✅ Sistema de Login
2. ✅ Módulo de Relatórios completo
3. ✅ Notificações
4. ✅ Melhorias visuais

Implemente e teste! 🐄📸✨