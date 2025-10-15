import 'package:get/get.dart';
import '../controllers/saude_controller.dart';

class SaudeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SaudeController());
  }
}
