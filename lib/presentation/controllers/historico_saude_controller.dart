import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/registro_saude_model.dart';
import '../../data/services/registro_saude_service.dart';

class HistoricoSaudeController extends GetxController {
  final RegistroSaudeService _service = RegistroSaudeService();

  var registros = <RegistroSaudeModel>[].obs;
  var isLoading = false.obs;
  AnimalModel? animal;
  var custoTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is AnimalModel) {
      animal = Get.arguments;
      carregarHistorico();
    }
  }

  Future<void> carregarHistorico() async {
    if (animal == null) return;

    try {
      isLoading.value = true;
      registros.value = await _service.listarPorAnimal(animal!.id!);
      custoTotal.value = await _service.calcularCustoTotal(animal!.id!);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar histórico: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
