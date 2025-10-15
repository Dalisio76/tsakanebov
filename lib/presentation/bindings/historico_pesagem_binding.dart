import 'package:get/get.dart';
import '../controllers/historico_pesagem_controller.dart';

class HistoricoPesagemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HistoricoPesagemController());
  }
}
