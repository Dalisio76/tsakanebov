import 'package:get/get.dart';
import '../../data/models/registro_saude_model.dart';
import '../../data/services/registro_saude_service.dart';

class AlertasSaudeController extends GetxController {
  final RegistroSaudeService _service = RegistroSaudeService();

  var alertas = <RegistroSaudeModel>[].obs;
  var isLoading = false.obs;
  var diasFiltro = 30.obs;

  @override
  void onInit() {
    super.onInit();
    carregarAlertas();
  }

  Future<void> carregarAlertas() async {
    try {
      isLoading.value = true;
      alertas.value = await _service.listarAlertas(dias: diasFiltro.value);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar alertas: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void alterarFiltro(int dias) {
    diasFiltro.value = dias;
    carregarAlertas();
  }

  // Agrupar alertas por urgência
  List<RegistroSaudeModel> get alertasVencidos {
    return alertas.where((a) => a.statusAlerta == 'vencido').toList();
  }

  List<RegistroSaudeModel> get alertasUrgentes {
    return alertas.where((a) => a.statusAlerta == 'urgente').toList();
  }

  List<RegistroSaudeModel> get alertasProximos {
    return alertas.where((a) => a.statusAlerta == 'proximo').toList();
  }
}
