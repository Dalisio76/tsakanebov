import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TesteController extends GetxController {
  final supabase = Supabase.instance.client;

  var grupos = [].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> testarConexao() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await supabase.from('grupos').select().order('nome');

      grupos.value = response;

      Get.snackbar(
        'Sucesso',
        'Conectado! ${response.length} grupos encontrados',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Erro', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
