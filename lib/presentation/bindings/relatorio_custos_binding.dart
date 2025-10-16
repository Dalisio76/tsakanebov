import 'package:get/get.dart';
import '../controllers/relatorio_custos_controller.dart';

class RelatorioCustosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RelatorioCustosController>(() => RelatorioCustosController());
  }
}
