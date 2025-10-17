import 'package:get/get.dart';
import '../controllers/partos_controller.dart';

class PartosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PartosController>(() => PartosController());
  }
}
