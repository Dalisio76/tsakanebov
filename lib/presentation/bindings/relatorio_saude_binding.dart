import 'package:get/get.dart';
import '../controllers/relatorio_saude_controller.dart';

class RelatorioSaudeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RelatorioSaudeController());
  }
}
