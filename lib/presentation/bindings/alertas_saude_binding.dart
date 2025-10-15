import 'package:get/get.dart';
import '../controllers/alertas_saude_controller.dart';

class AlertasSaudeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AlertasSaudeController());
  }
}
