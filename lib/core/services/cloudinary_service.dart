import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Credenciais do Cloudinary
  static const String cloudName = 'dgxqbqnrt';
  static const String uploadPreset = 'gestao-gado';

  // Upload de imagem para Cloudinary
  static Future<String?> uploadImagem({
    required Uint8List bytes,
    required String filename,
    String folder = 'gestao-gado/animais',
  }) async {
    try {
      print('📤 Iniciando upload para Cloudinary...');

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
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
