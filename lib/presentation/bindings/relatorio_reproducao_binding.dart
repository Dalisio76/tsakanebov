import 'package:get/get.dart';
import '../controllers/relatorio_reproducao_controller.dart';

class RelatorioReproducaoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatorioReproducaoController>(
        () => RelatorioReproducaoController());
  }
}
