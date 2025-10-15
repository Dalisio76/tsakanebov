import 'package:get/get.dart';
import '../controllers/historico_saude_controller.dart';

class HistoricoSaudeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HistoricoSaudeController());
  }
}
