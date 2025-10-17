import 'package:get/get.dart';
import '../controllers/coberturas_controller.dart';

class CoberturasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoberturasController>(() => CoberturasController());
  }
}
